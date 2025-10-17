

const String _envEndpoint = String.fromEnvironment('BACKEND_URL', defaultValue: '');
const String _envHealthEndpoint =
String.fromEnvironment('BACKEND_HEALTH_URL', defaultValue: '');

const String _defaultGenerateEndpoint =
    'https://us-central1-autism-a8f89.cloudfunctions.net/generate_game';
const String _defaultHealthEndpoint =
    'https://us-central1-autism-a8f89.cloudfunctions.net/health';

/// Returns the configured endpoint for generating AI practices.
///
/// A compile-time environment override (`BACKEND_URL`) takes precedence. When
/// no override is supplied the app falls back to the deployed Firebase Cloud
/// Function URL.

String get backendEndpoint {
  if (_envEndpoint.isNotEmpty) return _envEndpoint;
  return _defaultGenerateEndpoint;
}

/// Returns the configured health-check endpoint for the backend service.
///
/// Similar to [backendEndpoint], a compile-time override (`BACKEND_HEALTH_URL`)
/// can be provided when targeting a different backend instance.
String get backendHealthEndpoint {
  if (_envHealthEndpoint.isNotEmpty) return _envHealthEndpoint;
  return _defaultHealthEndpoint;
}