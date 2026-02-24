/// Platform-aware geocoder service.
/// Uses Maps JS API Geocoder on web, geocoding package on mobile.
export 'geocoder_service_stub.dart'
    if (dart.library.js_interop) 'geocoder_service_web.dart';
