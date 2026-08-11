# Clean Slate

A tiny native macOS utility with one button: quit every open app, which
clears their unpinned Dock icons and "currently open" indicator dots.
Pinned Dock icons are left completely untouched.

## What it does when you click "Quit All Apps"

Asks every regular, user-facing app (except Finder) to quit via
`NSRunningApplication.terminate()` — apps with unsaved changes get a chance
to prompt you first, same as quitting them normally. Once an app quits:

- If it wasn't pinned to the Dock, its icon disappears from the Dock.
- Either way, its "currently open" indicator dot disappears.

Nothing in the Dock's pinned-apps list (`com.apple.dock persistent-apps`)
is ever modified — this only quits apps, it doesn't touch your Dock layout.

A confirmation dialog appears before anything happens.

## Build the DMG without a Mac (GitHub Actions)

This repo includes `.github/workflows/build-dmg.yml`, which builds the app
on GitHub's real macOS runners and uploads the DMG as a downloadable
artifact.

1. Push this project to a GitHub repo.
2. Actions tab → "Build macOS DMG" → Run workflow (or push to `main`).
3. Download the `Clean-Slate-dmg` artifact — it contains `Clean Slate.dmg`.
4. First launch: since it's only ad-hoc signed (not notarized), right-click
   the app → Open to get past Gatekeeper.

## Build locally (if you ever have Mac access)

```bash
chmod +x build_dmg.sh
./build_dmg.sh
```

Produces `Clean Slate.dmg` in the project root.
