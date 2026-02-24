import 'dart:convert';
import 'package:http/http.dart' as http;

/// Geocode result containing coordinates and formatted address.
class GeocodeResult {
  final double lat;
  final double lng;
  final String formattedAddress;
  final String? error;

  GeocodeResult({
    required this.lat,
    required this.lng,
    required this.formattedAddress,
    this.error,
  });
}

/// Geocode an address using OpenStreetMap Nominatim (free, no API key needed).
/// Handles vague/partial searches well, similar to Google Maps.
Future<GeocodeResult?> geocodeAddress(String address) async {
  try {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
      '?q=${Uri.encodeComponent(address)}'
      '&format=json'
      '&limit=1'
      '&addressdetails=1',
    );

    final response = await http.get(url, headers: {
      'User-Agent': 'MyBandarApp/1.0',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      if (data.isNotEmpty) {
        final place = data[0];
        return GeocodeResult(
          lat: double.parse(place['lat']),
          lng: double.parse(place['lon']),
          formattedAddress: place['display_name'] as String,
        );
      }
    }

    return GeocodeResult(
      lat: 0,
      lng: 0,
      formattedAddress: '',
      error: 'No results found for "$address"',
    );
  } catch (e) {
    return GeocodeResult(
      lat: 0,
      lng: 0,
      formattedAddress: '',
      error: 'Error: $e',
    );
  }
}
