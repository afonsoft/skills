# Release Checklist

> Check each item before every release. Source of version information: The VERSION file must match the latest released version in CHANGELOG.md (CI version-check job automatically verifies, and it will fail if inconsistent).

## Release Steps

1. [ ] Confirm that the content of the [Unreleased] section in CHANGELOG.md is complete (Keep a Changelog groups: Added / Fixed / Security / Removed)
2. [ ] Change ## [Unreleased] to ## [x.y.z] — YYYY-MM-DD, and update the comparison link from ...HEAD to the new tag
3. [ ] Synchronously update the VERSION file to x.y.z
4. [ ] Milestone version (e.g., v1.0.0 / v1.1.0) synchronously updates docs/RELEASE_NOTES_v<x.y.z>.md
5. [ ] Tag: git tag v<x.y.z> + git push --tags
6. [ ] After pushing, confirm that the CI is all green (routing 173 baseline + coherence + pin gate + version-check)

## Metadata Synchronization (Convenient Step During Release)

- Add/Delete bootstrap capabilities → synchronize the capability lists in RULES.md / RULES_zh.md / references/README.md (using references/scripts/bootstrap-manifest.json as the only source of truth, currently 25 items)
- Add field-journal entry → Update references/field-journal/_index.md in three places (scene classification / high-frequency mode / entity inverted index) and statistics
- Routing rule change → only modify references/config/routing.json (the document is maintained by the generation script or at least kept consistent)

> Note: Journal entries are no longer manually maintained at the bottom <!-- [Evolution Statistics] --> Cumulative comments (removed on 2026-08-10, numbers cannot be reliably maintained), project counts are based on _index.md.