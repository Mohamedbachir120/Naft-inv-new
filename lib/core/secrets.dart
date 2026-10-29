/// Build-time credentials, injected with
/// `flutter run|build --dart-define-from-file=secrets.json`.
///
/// They are kept out of the source code but still end up in the compiled
/// APK, so they must not be treated as truly secret.
const String serviceAccountLogin =
    String.fromEnvironment('SERVICE_ACCOUNT_LOGIN');
const String serviceAccountPassword =
    String.fromEnvironment('SERVICE_ACCOUNT_PASSWORD');

/// Password shared by inventory team members (offline login and
/// auto-registration on the server).
const String defaultUserPassword =
    String.fromEnvironment('DEFAULT_USER_PASSWORD');

/// Throws early when the app was built without secrets.json, instead of
/// failing later with confusing authentication errors.
void ensureSecretsConfigured() {
  if (serviceAccountLogin.isEmpty ||
      serviceAccountPassword.isEmpty ||
      defaultUserPassword.isEmpty) {
    throw StateError(
        'Missing build secrets. Build with --dart-define-from-file=secrets.json '
        '(see secrets.example.json).');
  }
}
