import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as geo;
import '../../models/location_data.dart';
import '../../models/product.dart';

class LocationInput extends StatefulWidget {
  final Function setLocation;
  final Product product;

  LocationInput(this.setLocation, this.product);

  @override
  _LocationInputState createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  final FocusNode _addressInputFocusNode = FocusNode();
  LocationData _locationData;
  final TextEditingController _addressInputController = TextEditingController();
  Completer<GoogleMapController> _controller = Completer();
  List<Marker> markers = [];

  @override
  void initState() {
    _addressInputFocusNode.addListener(_updateLocation);
    if (widget.product != null) {
      _getStaticMap(widget.product.location.address, geocode: false);
    }

    super.initState();
  }

  @override
  void dispose() {
    _addressInputFocusNode.removeListener(_updateLocation);
    super.dispose();
  }

  void _getStaticMap(String address,
      {bool geocode = true, double lat, double lng}) async {
    if (address.isEmpty) {
      widget.setLocation(null);
      return;
    }

    if (geocode) {
      final Uri uri = Uri.https('eu1.locationiq.com', '/v1/search.php',
          {'key': 'b6700e435da4e4', 'q': address, 'format': 'json'});

      final http.Response response = await http.get(uri);
      final decodedResponse = json.decode(response.body);
      _locationData = LocationData(
          double.parse(decodedResponse[0]['lat']),
          double.parse(decodedResponse[0]['lon']),
          decodedResponse[0]['display_name']);
    } else if (lat == null && lng == null) {
      _locationData = LocationData(
        widget.product.location.latitude,
        widget.product.location.longitude,
        widget.product.location.address,
      );
    } else {
      _locationData = LocationData(
        lat,
        lng,
        address,
      );
    }

    final targetCoords =
        LatLng(_locationData.latitude, _locationData.longitude);
    final CameraPosition cameraPosition = CameraPosition(
//        bearing: 192.8334901395799,
      target: targetCoords,
//      tilt: 59.440717697143555,
      zoom: 19.151926040649414,
    );
    setMarker(targetCoords, MarkerId(_locationData.address));
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    widget.setLocation(_locationData);
    if (mounted) {
      setState(() {
        _addressInputController.text = _locationData.address;
      });
    }
  }

  void setMarker(LatLng coords, MarkerId markerId) {
    markers.add(Marker(
      markerId: markerId,
      position: coords,
    ));
  }

  void _updateLocation() {
    if (!_addressInputFocusNode.hasFocus) {
      _getStaticMap(_addressInputController.text);
    }
  }

  Future<String> _getAddress(double lat, double lng) async {
    final Uri uri = Uri.https('eu1.locationiq.com', '/v1/reverse.php', {
      'key': 'b6700e435da4e4',
      'lat': lat.toString(),
      'lon': lng.toString(),
      'format': 'json'
    });
    final http.Response response = await http.get(uri);
    final decodedResponse = json.decode(response.body);
    print(decodedResponse);
    final formattedAddress = decodedResponse['display_name'];
    return formattedAddress;
  }

  void _getUserLocation() async {
    final location = geo.Location();
    final currentLocation = await location.getLocation();
    final address =
        await _getAddress(currentLocation.latitude, currentLocation.longitude);
    _getStaticMap(address,
        geocode: false,
        lat: currentLocation.latitude,
        lng: currentLocation.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      TextFormField(
        controller: _addressInputController,
        focusNode: _addressInputFocusNode,
        validator: (String value) {
          if (_locationData == null || value.isEmpty) {
            return 'No valid location found';
          }
        },
        decoration: InputDecoration(labelText: 'Address'),
      ),
      SizedBox(
        height: 10.0,
      ),
      FlatButton(
        child: Text('Locate me'),
        onPressed: _getUserLocation,
      ),
      SizedBox(
        height: 10.0,
      ),
      SizedBox(
          width: 500.0,
          height: 300.0,
          child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: LatLng(41.40337, 2.17403),
                zoom: 17.0,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              myLocationButtonEnabled: false,
              markers: markers.toSet()))
    ]);
  }
}
