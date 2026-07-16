import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapMarkerHelper {
  const GoogleMapMarkerHelper._();

  static Future<BitmapDescriptor> createMarkerFromAsset(
    String assetPath, {
    int width = 100,
  }) async {
    try {
      final data = await rootBundle.load(assetPath);

      return BitmapDescriptor.bytes(
        data.buffer.asUint8List(),
        width: width.toDouble(),
      );
    } catch (_) {
      return BitmapDescriptor.defaultMarker;
    }
  }

  static Marker createMarker({
    required String markerId,
    required double latitude,
    required double longitude,
    required String title,
    required String snippet,
    required BitmapDescriptor icon,
    VoidCallback? onTap,
  }) {
    return Marker(
      markerId: MarkerId(markerId),
      position: LatLng(latitude, longitude),
      icon: icon,
      infoWindow: InfoWindow(title: title, snippet: snippet),
      onTap: onTap,
    );
  }
}
