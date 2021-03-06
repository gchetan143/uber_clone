import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:uber_clone/models/location_model.dart';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchApi {
  static Future<List<Place>> searchPlace(
      BuildContext context, String searchKey) async {
    List<Place> searchResult = new List();
    http.Response response = await http.get(
        "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?"
        "input=$searchKey&inputtype=textquery&fields=formatted_address,name,place_id&"
        "key=AIzaSyDS1Eq6__8-Cfb1_vizG1w9jPza8gkjhvI&"
        "locationbias=point:${Provider.of<LocationModel>(context, listen: false).currentLocation.latitude},"
        "${Provider.of<LocationModel>(context, listen: false).currentLocation.longitude}");
    if (response.statusCode == 200) {
      Map<String, dynamic> formattedResponse =
          JsonDecoder().convert(response.body);
      print(response.body);
      if (formattedResponse['status'] == "OK") {
        for (int x = 0; x < formattedResponse['candidates'].length; x++) {
          searchResult.add(Place.fromJson(formattedResponse['candidates'][x]));
        }
        return searchResult;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  static Future<Place> convertCoordinatesToAddress(LatLng coordinates) async {
    Place searchResult;
    http.Response response = await http.get(
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${coordinates.latitude},${coordinates.longitude}&key=AIzaSyDS1Eq6__8-Cfb1_vizG1w9jPza8gkjhvI");
    if (response.statusCode == 200) {
      Map<String, dynamic> formattedResponse =
          JsonDecoder().convert(response.body);
      print(response.body);
      if (formattedResponse['status'] == "OK") {
        searchResult = Place(
            formattedAddress: formattedResponse['results'][0]
                ['address_components'][0]['long_name'],
            name: formattedResponse['results'][0]['address_components'][0]
                ['short_name'],
            placeId: formattedResponse['results'][0]['place_id']);
        return searchResult;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }
}

class Place {
  String formattedAddress;
  String name;
  String placeId;

  Place({this.placeId, this.name, this.formattedAddress});

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
        formattedAddress: json['formatted_address'],
        name: json['name'],
        placeId: json['place_id']);
  }
}
