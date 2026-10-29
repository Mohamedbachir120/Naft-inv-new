# NaftInv

Flutter app used by NAFTAL inventory teams to scan localities and fixed assets
and synchronise them with the inventory backend.

## Build secrets

The service account and the default team password are not stored in the
source code. They are injected at build time:

1. Copy `secrets.example.json` to `secrets.json` (ignored by git) and fill in
   the values.
2. Pass the file to every Flutter command that builds or runs the app:

   ```sh
   flutter run --dart-define-from-file=secrets.json
   flutter build apk --release --dart-define-from-file=secrets.json
   ```

The app stops at start-up with a clear error if it was built without them.
