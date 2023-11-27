import 'dart:async';
//import 'dart:ffi';
import 'package:f_firebase_202210/data/model/user_location.dart';
import 'package:f_firebase_202210/domain/locator_service.dart';
//import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:loggy/loggy.dart';
import 'dart:math';

class LocationController extends GetxController {
  var userLocation = UserLocation(latitude: 0, longitude: 0).obs;
  final _liveUpdate = false.obs;
  final _distancia = 0.0.obs;

  StreamSubscription<UserLocation>? _positionStreamSubscription;
  LocatorService service = Get.find();
  bool get liveUpdate => _liveUpdate.value;
  bool changeMarkers = false;
  double get distancia => _distancia.value;

  clearLocation() {
    userLocation.value = UserLocation(latitude: 0, longitude: 0);
  }

  Future<void> getLocation(double lat1, double lon1, bool calcular) async {
    userLocation.value =
        await service.getLocation().onError((error, stackTrace) {
      return Future.error(error.toString());
    });
    logInfo(userLocation.value);
    if(calcular==true){_distancia.value = calcularDistancia(lat1, lon1, userLocation.value.latitude, userLocation.value.longitude);}
  }

  Future<void> subscribeLocationUpdates() async {
    logInfo('subscribeLocationUpdates');

    await service.startStream().onError((error, stackTrace) {
      logError(
          "Controller subscribeLocationUpdates got the error ${error.toString()}");
      return Future.error(error.toString());
    });

    _positionStreamSubscription = service.locationStream.listen((event) {
      logInfo("Controller event ${event.latitude}");
      userLocation.value = event;
    });
    _liveUpdate.value = true;
  }

  Future<void> unSubscribeLocationUpdates() async {
    logInfo('unSubscribeLocationUpdates');
    if (liveUpdate == false) {
      logInfo('unSubscribeLocationUpdates liveUpdate is false');
      return Future.value();
    }
    await service.stopStream().onError((error, stackTrace) {
      logError(
          "Controller unSubscribeLocationUpdates got the error ${error.toString()}");
      return Future.error(error.toString());
    });

    _liveUpdate.value = false;

    if (_positionStreamSubscription != null) {
      _positionStreamSubscription?.cancel();
    } else {
      logError("Controller _positionStreamSubscription is null");
    }
  }



  double calcularDistancia(double lat1, double lon1, double lat2, double lon2) {
  const radioTierra = 6371.0; // Radio de la Tierra en kilómetros
  final dLat = _gradosARadianes(lat2 - lat1);
  final dLon = _gradosARadianes(lon2 - lon1);

  final a = pow(sin(dLat / 2), 2) +
      cos(_gradosARadianes(lat1)) * cos(_gradosARadianes(lat2)) * pow(sin(dLon / 2), 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  final distancia = radioTierra * c;
  return distancia;
}

double _gradosARadianes(double grados) {
  return grados * pi / 180.0;
}




}
