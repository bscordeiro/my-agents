# Security Checklist

Apply to changed behavior involving external input, authentication/authorization,
sensitive data, file access, outbound requests, or plan-marked security/privacy risk.
Evaluate affected paths, not only new endpoints. For each applicable item, record evidence
in the existing review/progress record; mark exclusions with a reason, not an unchecked guess.

- **Injection:** validate at trust boundaries; parameterize queries and avoid shell
  interpolation of untrusted values.
- **XSS:** encode untrusted output for its rendering context (HTML, JavaScript, attributes).
- **SSRF:** validate destinations, resolved addresses, and redirects against the permitted
  network policy; reject unintended private/internal destinations.
- **Path traversal:** verify containment within the authorized directory after path
  normalization/resolution, including symlink behavior for the access mechanism. A fixed
  string prefix alone is insufficient; account for races when untrusted users can alter paths.
- **Open redirects:** restrict redirect destinations to the intended origins or local paths.
- **Auth:** verify identity and authorization on affected operations and objects, including
  cross-user/tenant denial cases and existing endpoints whose policies changed.
- **CSRF and abuse:** assess cookie-authenticated state changes, rate limits, and resource
  bounds. Document why a protection is unnecessary when excluding it.
- **Sensitive data:** minimize collection, retention, and access; use appropriate encryption
  and key management for stored data and credentials.
- **Logs and errors:** redact secrets, tokens, and PII from diagnostics and test evidence;
  report presence or sanitized metadata rather than dumping values.

Fix vulnerabilities introduced by the increment before declaring it complete and verify
relevant denial/error paths. Report pre-existing or out-of-scope findings; escalate when
safe delivery requires a scope, compatibility, or data-handling decision. A prior approval
remains valid unless new evidence introduces a material risk or unresolved choice.
