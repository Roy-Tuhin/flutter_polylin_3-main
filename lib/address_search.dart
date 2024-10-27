import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_polylin_3/autocomplete_prediction.dart';
import 'package:flutter_polylin_3/map_widget.dart';
import 'package:flutter_polylin_3/models/place_auto_complate_response.dart';
import 'package:flutter_polylin_3/network_utility.dart';

class AddressSearchScreen extends StatefulWidget {
  const AddressSearchScreen({super.key});

  @override
  State<AddressSearchScreen> createState() => _AddressSearchScreenState();
}

class _AddressSearchScreenState extends State<AddressSearchScreen> {
  List<AutocompletePrediction> placePredictions = [];
  TextEditingController sourceAddressSearch = TextEditingController();
  TextEditingController destinationAddressSearch = TextEditingController();
  String? focusedField;
  var sourceLatitude,
      sourceLongitude,
      destinationLatitude,
      destinationLongitude;

  void placeAutoComplete(String query) async {
    Uri uri =
        Uri.https('maps.googleapis.com', 'maps/api/place/autocomplete/json', {
      "input": query,
      "key": "put_your_google_api_key_here",
    });

    String? response = await NetworkUtility.fetchUrl(uri);
    if (response != null) {
      print(response);
      PlaceAutocompleteResponse result =
          PlaceAutocompleteResponse.parseAutocompleteResult(response);

      if (result.predictions != null) {
        setState(() {
          placePredictions = result.predictions!;
        });
      }
    }
  }

  fetchPlaceDetails(String placeId, int index) async {
    Uri uri = Uri.https('maps.googleapis.com', 'maps/api/place/details/json', {
      "place_id": placeId,
      "key": "put_your_google_api_key_here",
    });

    String? response = await NetworkUtility.fetchUrl(uri);
    if (response != null) {
      final Map<String, dynamic> result = jsonDecode(response);
      if (result['status'] == 'OK') {
        final location = result['result']['geometry']['location'];
        final double latitude = location['lat'];
        final double longitude = location['lng'];

        setState(() {
          placePredictions[index].latitude = latitude;
          placePredictions[index].longitude = longitude;
        });
      } else {
        print('Error: ${result['status']}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(18.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff5A4CE5),
          ),
          onPressed: () {
            if (sourceLatitude != null &&
                sourceLongitude != null &&
                destinationLatitude != null &&
                destinationLongitude != null) {
              print('Source: $sourceLatitude, $sourceLongitude');
              print('Destination: $destinationLatitude, $destinationLongitude');

              Navigator.push(context, MaterialPageRoute(
                builder: (context) => MapWidget(
                  sourceLat: sourceLatitude,
                  sourceLng: sourceLongitude,
                  destLat: destinationLatitude,
                  destLng: destinationLongitude,
                ),
              ));
            } else {
              print('Please select both source and destination addresses.');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Please select both source and destination addresses'),
                ),
              );
            }
          },
          child: const Text(
            'Next',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(220.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xff5A4CE5),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_sharp,
                              color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
                      Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: const Row(
                            children: [
                              Text(
                                "Car Taxi",
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Icon(Icons.arrow_drop_down, color: Colors.white),
                            ],
                          )),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: IconButton(
                          icon:
                              const Icon(Icons.more_horiz, color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(12), // Rounded corners
                    ),
                    child: TextFormField(
                      onChanged: (value) {
                        placeAutoComplete(value);
                      },
                      onTap: () {
                        setState(() {
                          focusedField = 'sourceAddressSearch';
                        });
                      },
                      controller: sourceAddressSearch,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'From',
                        hintStyle: TextStyle(color: Colors.white),
                        helperStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius:
                          BorderRadius.circular(12), // Rounded corners
                    ),
                    child: TextFormField(
                      onChanged: (value) {
                        placeAutoComplete(value);
                      },
                      onTap: () {
                        setState(() {
                          focusedField = 'destinationAddressSearch';
                        });
                      },
                      controller: destinationAddressSearch,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'To',
                        hintStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: placePredictions.length,
              itemBuilder: (context, index) => ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withOpacity(0.2),
                  ),
                  child: const Icon(Icons.home, color: Colors.orange),
                ),
                title: GestureDetector(
                  onTap: () async {
                    await fetchPlaceDetails(
                        placePredictions[index].placeId!, index);

                    setState(() {
                      if (focusedField == 'sourceAddressSearch') {
                        sourceAddressSearch.text =
                            placePredictions[index].description!;
                        sourceLatitude = placePredictions[index].latitude;
                        sourceLongitude = placePredictions[index].longitude;
                      } else if (focusedField == 'destinationAddressSearch') {
                        destinationAddressSearch.text =
                            placePredictions[index].description!;
                        destinationLatitude = placePredictions[index].latitude;
                        destinationLongitude =
                            placePredictions[index].longitude;
                      }
                    });

                    print(
                        '=========>Source: $sourceLatitude, $sourceLongitude, Destination: $destinationLatitude, $destinationLongitude');
                  },
                  child: Text(placePredictions[index].description!),
                ),
                subtitle: placePredictions[index].latitude != null &&
                        placePredictions[index].longitude != null
                    ? Text(
                        'Lat: ${placePredictions[index].latitude}, Lng: ${placePredictions[index].longitude}')
                    : null, // Show subtitle only if lat-lng is available
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
            ),
          )
        ],
      ),
    );
  }
}
