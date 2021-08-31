import 'package:location/location.dart';

class PCRTestService {
  final Location location = new Location();

  late PermissionStatus _permissionGranted;
  late bool _serviceEnabled;
  late double longtitude;

  void isServiceEnabled() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
  }

  void isPermissionGranted() async {
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  Future<double?> getLongitude() async {
    LocationData locationData = await location.getLocation();

    double? longitude = locationData.longitude;
    return longitude;
  }

  Future<double?> getLatitude() async {
    LocationData locationData = await location.getLocation();

    double? latitude = locationData.latitude;
    return latitude;
  }
}
