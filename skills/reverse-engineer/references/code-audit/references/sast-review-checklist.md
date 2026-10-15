# Code audit checklist (simplified)

- [ ] List of all external input entries
- [ ] Authentication/authentication middleware coverage
- [ ] Whether the multi-tenant ID is bound to the session
- [ ] Deserialize / pickle / YAML load
- [ ] SSRF outbound and protocol restrictions
- [ ] Key and token storage
- [ ] File upload path and type
- [ ] Danger exec/system/Runtime