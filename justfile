# Justfile for dpad_qualification
# Local-first development, verification, and publishing without GitHub Actions billing.

set dotenv-load := false

# Default: List all available recipes
default:
    @just --list

# ------------------------------------------------------------------------------
# Dependencies & Setup
# ------------------------------------------------------------------------------

# Fetch dependencies for both root package and example app
get:
    flutter pub get
    (cd example && flutter pub get)

# Clean Flutter and build caches
clean:
    flutter clean
    (cd example && flutter clean)

# ------------------------------------------------------------------------------
# Quality & Verification (Local CI)
# ------------------------------------------------------------------------------

# Automatically format all Dart files
format:
    dart format .

# Verify formatting without modifying files (fails if unformatted)
format-check:
    dart format --output=none --set-exit-if-changed .

# Run static analysis with fatal infos on package and example
analyze:
    flutter analyze --fatal-infos
    (cd example && flutter analyze --fatal-infos)

# Run test suites for root package and example app
test:
    flutter test
    (cd example && flutter test)

# Run full local verification (format-check, analyze, test)
check: format-check analyze test
    @echo ""
    @echo "✅ All local verification checks passed successfully!"

# ------------------------------------------------------------------------------
# Packaging & Publishing
# ------------------------------------------------------------------------------

# Validate package before publishing (dry run)
dry-run:
    @git diff-index --quiet HEAD -- || (echo "⚠️  Working tree is not clean. Stash or commit before publishing." && exit 1)
    dart pub publish --dry-run

# Publish package to pub.dev using local credentials (prompts for confirmation)
publish: check dry-run
    @echo ""
    @echo "🚀 Publishing to pub.dev using local credentials..."
    dart pub publish

# Force publish package to pub.dev using local credentials (skips prompt)
publish-force: check dry-run
    @echo ""
    @echo "🚀 Force publishing to pub.dev using local credentials..."
    dart pub publish --force

# ------------------------------------------------------------------------------
# Release Management (Local)
# ------------------------------------------------------------------------------

# Create an annotated git tag and publish a GitHub release locally
release version:
    @git diff-index --quiet HEAD -- || (echo "⚠️  Working tree is not clean. Stash or commit before releasing." && exit 1)
    git tag -a "v{{version}}" -m "Release dpad_qualification {{version}}"
    git push origin "v{{version}}"
    gh release create "v{{version}}" --title "v{{version}}" --generate-notes
    @echo ""
    @echo "🎉 Released v{{version}} successfully!"
