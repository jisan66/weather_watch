import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../Widgets/custom_toast.dart';

class LocationService {
  Future<Position> requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;



      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Geolocator.openLocationSettings();
        return Future.error('Location services are disabled. Please turn on location and refresh');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      return await Geolocator.getCurrentPosition();

  }

  Future<List<String>> getAddress() async {

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none){

      showToast("Please, Enable device internet connection.");
      return Future.error('No Internet Connection');

    }
    else {
      String address = '';
      var access = await requestLocationPermission();
      try {
        List<Placemark> placeMark =
            await placemarkFromCoordinates(access.latitude, access.longitude);
        if (placeMark.isNotEmpty) {
          Placemark placemark = placeMark.first;
          address = '${placemark.locality}, ${placemark.country}' ??
              'Unable to get location';
          // address = removeSpecialCharacters(address);
        }
        return [
          access.latitude.toString(),
          access.longitude.toString(),
          address
        ];
      } catch (e) {
        showToast("Please check your internet connection.");
      }
      return [];
    }
  }

  // String removeSpecialCharacters(String address) {
  //   // Regular expression to match special characters
  //   RegExp specialCharRegex = RegExp(r'[^\w\s,]');
  //
  //   // Replace special characters with an empty string
  //   return address.replaceAll(specialCharRegex, '');
  // }
}
