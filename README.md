# Clean Slate

A tiny native macOS utility with one button: quit every open app and clear
every pinned icon from the Dock.

## What it does when you click "Quit All & Clear Dock"

1. Asks every regular, user-facing app (except Finder) to quit via
   `NSRunningApplication.terminate()` — apps with unsaved changes get a
   chance to prompt you first, same as quitting them normally.
2. Backs up your current Dock layout (`defaults export com.apple.dock …`)
   to `~/Library/Application Support/CleanSlate/dock-backup.plist`.
3. Clears the Dock's pinned-apps list (`defaults write com.apple.dock
   persistent-apps -array`) and restarts the Dock process so the change
   shows immediately. Since every other app was just quit, their
   "currently open" indicator dots disappear along with them.

A confirmation dialog appears before anything happens, and a "Restore Dock"
button un-does the Dock wipe using the automatic backup (does not relaunch
quit apps).

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
