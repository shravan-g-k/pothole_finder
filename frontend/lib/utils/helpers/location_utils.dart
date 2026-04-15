import 'package:frontend/utils/exceptions/location_exception.dart';
import 'package:frontend/utils/helpers/permission_utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationUtils {
  /// Fetches the current location of the user.
  /// Throws an exception if location services are disabled or permissions are denied.
  static Future<LatLng> getCurrentLocation() async {
    final hasPermission = await PermissionUtils.handleLocationPermission();
    if (!hasPermission) {
      throw LocationPermissionDeniedException("Location permissions are denied");
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  static Stream<Position> getLocationStream()  {
   
    return Geolocator.getPositionStream(
      locationSettings: AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 2, // Trigger every 2 meters
        intervalDuration: const Duration(milliseconds: 500),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText: 'Tracking location for navigation',
          notificationTitle: 'Navigation Active',
          enableWakeLock: true, // Prevent CPU sleep
        ),
      ),
    );
  }
}
