#!/usr/bin/env bash
set -euo pipefail

usage() {
	cat <<'EOF'
Usage: sync-skills.sh [--dry-run] [--help]

Synchronize curated skills at upstream default-branch tip.
Repositories track latest to receive fixes promptly; review the diff after sync.

Options:
  --dry-run  Show exact file changes without changing installed skills.
  -h, --help Show this help.
EOF
}

DRY_RUN=0
for argument in "$@"; do
	case "$argument" in
	--dry-run) DRY_RUN=1 ;;
	-h | --help)
		usage
		exit 0
		;;
	*)
		printf 'Unknown option: %s\n' "$argument" >&2
		usage >&2
		exit 2
		;;
	esac
done

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR"
LOCK_FILE="$SCRIPT_DIR/../.skill-lock.json"

# Format: repository_key|repository_url
# Tracks the remote default branch tip to receive upstream fixes promptly.
REPOSITORIES=(
	"juliusbrussee|https://github.com/JuliusBrussee/skills.git"
	"mattpocock|https://github.com/mattpocock/skills.git"
	"multica-karpathy|https://github.com/multica-ai/andrej-karpathy-skills.git"
	"obra-superpowers|https://github.com/obra/superpowers.git"
	"addyosmani|https://github.com/addyosmani/agent-skills.git"
)

# Format: local_name|repository_key|path_inside_repository
# Skills tracked by .skill-lock.json are deliberately excluded from this list.
# Locally maintained skills (including planmate, xpmate, reviewmate, and pr-audit)
# stay outside SOURCES and the external-install lock; do not overwrite local policy.
SOURCES=(
	"caveman|juliusbrussee|skills/caveman"
	"tdd|mattpocock|skills/engineering/tdd"
	"grilling|mattpocock|skills/productivity/grilling"
	"codebase-design|mattpocock|skills/engineering/codebase-design"
	"domain-modeling|mattpocock|skills/engineering/domain-modeling"
	"improve-codebase-architecture|mattpocock|skills/engineering/improve-codebase-architecture"
	"karpathy-guidelines|multica-karpathy|skills/karpathy-guidelines"
	"brainstorming|obra-superpowers|skills/brainstorming"
	"verification-before-completion|obra-superpowers|skills/verification-before-completion"
	"systematic-debugging|obra-superpowers|skills/systematic-debugging"
	"test-driven-development|obra-superpowers|skills/test-driven-development"
	"code-review-and-quality|addyosmani|skills/code-review-and-quality"
)

if [[ -t 1 ]]; then
	RED='\033[0;31m'
	GREEN='\033[0;32m'
	YELLOW='\033[1;33m'
	BLUE='\033[0;34m'
	NC='\033[0m'
else
	RED=''
	GREEN=''
	YELLOW=''
	BLUE=''
	NC=''
fi

log() { printf '%b[✓]%b %s\n' "$GREEN" "$NC" "$1"; }
warn() { printf '%b[!]%b %s\n' "$YELLOW" "$NC" "$1"; }
error() { printf '%b[✗]%b %s\n' "$RED" "$NC" "$1" >&2; }
info() { printf '%b[i]%b %s\n' "$BLUE" "$NC" "$1"; }

for required_command in git rsync jq find realpath readlink awk; do
	command -v "$required_command" >/dev/null 2>&1 || {
		printf 'Required command not found: %s\n' "$required_command" >&2
		exit 1
	}
done

[[ -d "$SKILLS_DIR" ]] || {
	error "Skills directory not found: $SKILLS_DIR"
	exit 1
}

declare -A REPOSITORY_URLS=()
declare -A REPOSITORY_RESOLVED=()
declare -A REPOSITORY_CHECKOUTS=()
declare -A FAILED_REPOSITORIES=()
declare -A LOCK_MANAGED_SKILLS=()
declare -A ACTIVE_REPOSITORIES=()
declare -A SEEN_SKILLS=()
REPOSITORY_KEYS=()
ACTIVE_SOURCES=()
ERRORS=()
ADDED=()
UPDATED=()
UNCHANGED=()
WOULD_ADD=()
WOULD_UPDATE=()
SKIPPED_LOCK_MANAGED=()
RUN_TEMP_DIR=''
ACTIVE_DESTINATION=''
ACTIVE_BACKUP=''

record_error() {
	error "$1"
	ERRORS+=("$2")
}

cleanup() {
	local status=$?
	trap - EXIT
	if [[ -n "$ACTIVE_BACKUP" && -e "$ACTIVE_BACKUP" && ! -e "$ACTIVE_DESTINATION" ]]; then
		mv -- "$ACTIVE_BACKUP" "$ACTIVE_DESTINATION" 2>/dev/null || true
	fi
	[[ -z "$RUN_TEMP_DIR" ]] || rm -rf -- "$RUN_TEMP_DIR"
	exit "$status"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
trap 'exit 129' HUP

load_repositories() {
	local entry key url extra
	for entry in "${REPOSITORIES[@]}"; do
		IFS='|' read -r key url extra <<<"$entry"
		if [[ -n "${extra:-}" || ! "$key" =~ ^[a-z0-9-]+$ ]]; then
			record_error "Invalid repository entry: $entry" "$key (invalid configuration)"
			continue
		fi
		if [[ ! "$url" =~ ^https://github\.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+\.git$ ]]; then
			record_error "Repository URL is not allowlisted: $url" "$key (invalid URL)"
			continue
		fi
		if [[ -n "${REPOSITORY_URLS[$key]:-}" ]]; then
			record_error "Duplicate repository key: $key" "$key (duplicate repository)"
			continue
		fi
		REPOSITORY_KEYS+=("$key")
		REPOSITORY_URLS["$key"]=$url
	done
}

load_lock_managed_skills() {
	local skill_name
	[[ -e "$LOCK_FILE" ]] || return 0
	if ! jq -e '(.version | type == "number") and (.skills | type == "object")' "$LOCK_FILE" >/dev/null; then
		record_error "Invalid skill lock file: $LOCK_FILE" "skill lock (invalid JSON)"
		return 1
	fi
	while IFS= read -r skill_name; do
		LOCK_MANAGED_SKILLS["$skill_name"]=1
		SKIPPED_LOCK_MANAGED+=("$skill_name")
		info "Lock-managed: $skill_name"
	done < <(jq -r '.skills | keys[]' "$LOCK_FILE" | sort)
}

load_sources() {
	local entry local_name repository_key repository_path extra
	for entry in "${SOURCES[@]}"; do
		IFS='|' read -r local_name repository_key repository_path extra <<<"$entry"
		if [[ -n "${extra:-}" || ! "$local_name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
			record_error "Invalid skill entry: $entry" "$local_name (invalid configuration)"
			continue
		fi
		if [[ -n "${SEEN_SKILLS[$local_name]:-}" ]]; then
			record_error "Duplicate skill name: $local_name" "$local_name (duplicate skill)"
			continue
		fi
		SEEN_SKILLS["$local_name"]=1
		if [[ -n "${LOCK_MANAGED_SKILLS[$local_name]:-}" ]]; then
			warn "Skipping lock-managed skill from custom sources: $local_name"
			continue
		fi
		if [[ -z "${REPOSITORY_URLS[$repository_key]:-}" ]]; then
			record_error "Unknown repository key '$repository_key' for $local_name" "$local_name (unknown repository)"
			continue
		fi
		if [[ "$repository_path" == /* || "/$repository_path/" == *"/../"* ]]; then
			record_error "Unsafe repository path for $local_name: $repository_path" "$local_name (unsafe path)"
			continue
		fi
		ACTIVE_SOURCES+=("$local_name|$repository_key|$repository_path")
		ACTIVE_REPOSITORIES["$repository_key"]=1
	done
}

clone_repositories() {
	local key url checkout actual_revision
	mkdir -p "$RUN_TEMP_DIR/repositories"
	for key in "${REPOSITORY_KEYS[@]}"; do
		[[ -n "${ACTIVE_REPOSITORIES[$key]:-}" ]] || continue
		url=${REPOSITORY_URLS[$key]}
		checkout="$RUN_TEMP_DIR/repositories/$key"
		info "Cloning $key (default branch tip)"
		if ! git clone --quiet --filter=blob:none -- "$url" "$checkout"; then
			record_error "Failed to clone $url" "$key (clone failed)"
			FAILED_REPOSITORIES["$key"]=1
			continue
		fi
		if ! actual_revision=$(git -C "$checkout" rev-parse HEAD); then
			record_error "Failed to resolve revision for $key" "$key (revision check failed)"
			FAILED_REPOSITORIES["$key"]=1
			continue
		fi
		REPOSITORY_RESOLVED["$key"]=$actual_revision
		info "Resolved $key to $actual_revision"
		REPOSITORY_CHECKOUTS["$key"]=$checkout
	done
}

frontmatter_field() {
	local skill_file=$1
	local field=$2
	awk -v requested_field="$field" '
        NR == 1 {
            if ($0 != "---") exit
            in_frontmatter = 1
            next
        }
        in_frontmatter && $0 == "---" { exit }
        in_frontmatter {
            prefix = "^" requested_field ":[[:space:]]*"
            if ($0 ~ prefix) {
                sub(prefix, "")
                gsub(/^[\047\042]|[\047\042]$/, "")
                print
                exit
            }
        }
    ' "$skill_file"
}

validate_symlinks() {
	local source_path=$1
	local link target resolved_source resolved_target
	resolved_source=$(realpath -m -- "$source_path")
	while IFS= read -r -d '' link; do
		target=$(readlink -- "$link") || {
			record_error "Cannot read symlink: $link" "$(basename "$source_path") (invalid symlink)"
			return 1
		}
		if [[ "$target" == /* ]]; then
			resolved_target=$(realpath -m -- "$target")
		else
			resolved_target=$(realpath -m -- "$(dirname -- "$link")/$target")
		fi
		case "$resolved_target" in
		"$resolved_source" | "$resolved_source"/*) ;;
		*)
			record_error "Unsafe symlink in $source_path: $link -> $target" "$(basename "$source_path") (unsafe symlink)"
			return 1
			;;
		esac
	done < <(find "$source_path" -type l -print0)
}

validate_skill() {
	local source_path=$1
	local expected_name=$2
	local skill_file="$source_path/SKILL.md"
	local actual_name description
	if [[ ! -s "$skill_file" ]]; then
		record_error "SKILL.md not found or empty: $skill_file" "$expected_name (SKILL.md not found)"
		return 1
	fi
	actual_name=$(frontmatter_field "$skill_file" name)
	description=$(frontmatter_field "$skill_file" description)
	if [[ "$actual_name" != "$expected_name" ]]; then
		record_error "Skill name mismatch for $expected_name: found '${actual_name:-missing}'" "$expected_name (name mismatch)"
		return 1
	fi
	if [[ -z "$description" ]]; then
		record_error "Skill description missing for $expected_name" "$expected_name (description missing)"
		return 1
	fi
	validate_symlinks "$source_path"
}

show_changes() {
	local skill_name=$1
	local changes=$2
	local line
	while IFS= read -r line; do
		[[ -z "$line" ]] || info "  $skill_name: $line"
	done <<<"$changes"
}

replace_destination() {
	local skill_name=$1
	local staged_path=$2
	local destination_path=$3
	local backup_path="$RUN_TEMP_DIR/backups/$skill_name"
	mkdir -p "$(dirname -- "$backup_path")"

	ACTIVE_DESTINATION=$destination_path
	ACTIVE_BACKUP=''
	if [[ -e "$destination_path" ]]; then
		ACTIVE_BACKUP=$backup_path
		if ! mv -- "$destination_path" "$backup_path"; then
			record_error "Failed to stage existing destination: $destination_path" "$skill_name (backup failed)"
			ACTIVE_DESTINATION=''
			ACTIVE_BACKUP=''
			return 1
		fi
	fi
	if ! mv -- "$staged_path" "$destination_path"; then
		[[ -z "$ACTIVE_BACKUP" ]] || mv -- "$ACTIVE_BACKUP" "$destination_path" 2>/dev/null || true
		record_error "Failed to install staged skill: $skill_name" "$skill_name (install failed)"
		ACTIVE_DESTINATION=''
		ACTIVE_BACKUP=''
		return 1
	fi
	ACTIVE_DESTINATION=''
	ACTIVE_BACKUP=''
}

sync_skill() {
	local local_name=$1
	local source_path=$2
	local destination_path="$SKILLS_DIR/$local_name"
	local existed=0 changes staged_path

	if [[ -L "$destination_path" || (-e "$destination_path" && ! -d "$destination_path") ]]; then
		record_error "Destination must be a real directory: $destination_path" "$local_name (invalid destination)"
		return 1
	fi
	[[ -d "$destination_path" ]] && existed=1
	if ! changes=$(LC_ALL=C rsync -a -n -i --checksum --no-times --omit-dir-times --safe-links --out-format='%i %n%L' -- "$source_path/" "$destination_path/" 2>&1); then
		record_error "Failed to compare $local_name: $changes" "$local_name (comparison failed)"
		return 1
	fi
	if [[ -z "$changes" ]]; then
		info "Unchanged: $local_name"
		UNCHANGED+=("$local_name")
		return 0
	fi
	show_changes "$local_name" "$changes"
	if ((DRY_RUN)); then
		if ((existed)); then
			info "Would update: $local_name"
			WOULD_UPDATE+=("$local_name")
		else
			info "Would add: $local_name"
			WOULD_ADD+=("$local_name")
		fi
		return 0
	fi

	staged_path="$RUN_TEMP_DIR/staging/$local_name"
	mkdir -p "$staged_path"
	if ((existed)) && ! rsync -a -- "$destination_path/" "$staged_path/"; then
		record_error "Failed to preserve existing files for $local_name" "$local_name (preservation failed)"
		return 1
	fi
	if ! rsync -a --checksum --no-times --omit-dir-times --safe-links -- "$source_path/" "$staged_path/"; then
		record_error "Failed to stage $local_name" "$local_name (staging failed)"
		return 1
	fi
	validate_skill "$staged_path" "$local_name" || return 1
	replace_destination "$local_name" "$staged_path" "$destination_path" || return 1
	if ((existed)); then
		log "Updated: $local_name"
		UPDATED+=("$local_name")
	else
		log "Added: $local_name"
		ADDED+=("$local_name")
	fi
}

print_summary_list() {
	local label=$1
	shift
	if (($# > 0)); then
		info "$label: $*"
	else
		info "$label: none"
	fi
}

load_repositories
load_lock_managed_skills || true
load_sources
if ((${#ERRORS[@]} > 0)); then
	warn "Preflight errors: ${ERRORS[*]}"
	exit 1
fi

RUN_TEMP_DIR=$(mktemp -d "$SCRIPT_DIR/../.sync-skills.XXXXXX")
clone_repositories

for source_entry in "${ACTIVE_SOURCES[@]}"; do
	IFS='|' read -r local_name repository_key repository_path <<<"$source_entry"
	if [[ -n "${FAILED_REPOSITORIES[$repository_key]:-}" ]]; then
		record_error "Repository unavailable for $local_name: $repository_key" "$local_name (repository unavailable)"
		continue
	fi
	source_path="${REPOSITORY_CHECKOUTS[$repository_key]:-}/$repository_path"
	if [[ ! -d "$source_path" ]]; then
		record_error "Source path not found for $local_name: $repository_path" "$local_name (source path not found)"
		continue
	fi
	validate_skill "$source_path" "$local_name" || continue
	sync_skill "$local_name" "$source_path" || true
done

printf '\n'
((DRY_RUN)) && info "DRY RUN — installed skills were not changed"
info "═══════════════════════════════"
info "  Sync complete"
info "═══════════════════════════════"
print_summary_list "Added" "${ADDED[@]}"
print_summary_list "Updated" "${UPDATED[@]}"
print_summary_list "Would add" "${WOULD_ADD[@]}"
print_summary_list "Would update" "${WOULD_UPDATE[@]}"
print_summary_list "Unchanged" "${UNCHANGED[@]}"
print_summary_list "Lock-managed" "${SKIPPED_LOCK_MANAGED[@]}"
if ((${#ERRORS[@]} > 0)); then
	warn "Errors: ${ERRORS[*]}"
	exit 1
fi
info "Errors: none"
printf '\n'
