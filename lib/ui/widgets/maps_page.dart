import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const MAPBOX_ACCESS_TOKEN =
    'pk.eyJ1IjoicGl0bWFjIiwiYSI6ImNsY3BpeWxuczJhOTEzbnBlaW5vcnNwNzMifQ.ncTzM4bW-jpq-hUFutnR1g';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? myPosition;
  LatLng? selectedPosition;
  LatLng? fixedPosition;
  double? distance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Position> determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('error');
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  void getCurrentLocation() async {
    Position position = await determinePosition();
    setState(() {
      myPosition = LatLng(position.latitude, position.longitude);
      print(myPosition);
    });
  }

  Future<void> getFixedLocation() async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('ubicaciones_fijas').doc('fixed_location').get();

      if (snapshot.exists) {
        setState(() {
          fixedPosition = LatLng(
            snapshot['latitudFija'],
            snapshot['longitudFija'],
          );
        });
      }
    } catch (e) {
      print('Error al obtener la ubicación fija: $e');
    }
  }

  void fixLocation(LatLng location) async {
    try {
      await _firestore.collection('ubicaciones_fijas').doc('fixed_location').set({
        'latitudFija': location.latitude,
        'longitudFija': location.longitude,
      });

      setState(() {
        fixedPosition = location;
      });
    } catch (e) {
      print('Error al fijar la ubicación: $e');
    }
  }

  void handleMapTap(LatLng tappedPoint) {
    setState(() {
      selectedPosition = tappedPoint;
    });

    // Calcula la distancia entre las dos ubicaciones
    if (myPosition != null && selectedPosition != null) {
      distance = Geolocator.distanceBetween(
        myPosition!.latitude,
        myPosition!.longitude,
        selectedPosition!.latitude,
        selectedPosition!.longitude,
      );

      print('Distancia: $distance metros');

      // Guarda la ubicación seleccionada en la base de datos
      fixLocation(selectedPosition!);
    }
  }

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      getCurrentLocation();
      getFixedLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Mapa'),
        backgroundColor: Colors.blueAccent,
      ),
      body: myPosition == null
          ? const CircularProgressIndicator()
          : FlutterMap(
              options: MapOptions(
                center: myPosition,
                minZoom: 5,
                maxZoom: 25,
                zoom: 18,
                onTap: (point) => handleMapTap(point),
              ),
              layers: [
                TileLayerOptions(
                  urlTemplate:
                      'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                  additionalOptions: const {
                    'accessToken': MAPBOX_ACCESS_TOKEN,
                    'id': 'mapbox/streets-v12',
                  },
                ),
                MarkerLayerOptions(
                  markers: [
                    Marker(
                      point: myPosition!,
                      builder: (context) {
                        return Container(
                          child: const Icon(
                            Icons.person_pin,
                            color: Colors.blueAccent,
                            size: 40,
                          ),
                        );
                      },
                    ),
                    if (fixedPosition != null)
                      Marker(
                        point: fixedPosition!,
                        builder: (context) {
                          return Container(
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          );
                        },
                      ),
                    if (selectedPosition != null)
                      Marker(
                        point: selectedPosition!,
                        builder: (context) {
                          return Container(
                            child: const Icon(
                              Icons.place,
                              color: Colors.green,
                              size: 40,
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ],
            ),
      floatingActionButton: distance != null
          ? FloatingActionButton.extended(
              onPressed: () {},
              label: Text('Distancia: ${distance!.toStringAsFixed(2)} metros'),
            )
          : null,
    );
  }
}
