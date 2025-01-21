import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

LatLngBounds getBoundsFromMarkers(List<LatLng> markers) {
  if (markers.isEmpty) {
    throw ArgumentError('Marker list cannot be empty');
  }

  double minLat = markers.first.latitude;
  double maxLat = markers.first.latitude;
  double minLng = markers.first.longitude;
  double maxLng = markers.first.longitude;

  for (var marker in markers) {
    if (marker.latitude < minLat) minLat = marker.latitude;
    if (marker.latitude > maxLat) maxLat = marker.latitude;
    if (marker.longitude < minLng) minLng = marker.longitude;
    if (marker.longitude > maxLng) maxLng = marker.longitude;
  }

  return LatLngBounds(
    LatLng(minLat, minLng), // Southwest corner
    LatLng(maxLat, maxLng), // Northeast corner
  );
}