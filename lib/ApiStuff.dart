import 'package:fincauselist/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:fincauselist/listpage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fincauselist/about.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';


Future<List<dynamic>> fetchCasesAllAdv(BuildContext context, {int page = 1, int limit = 20}) async {
  final selectedCourt = Provider.of<AppState>(context, listen: false).selected_court;
  final date = Provider.of<AppState>(context, listen: false).mainDate;
  // String oldlink = "https://causelistapi.onrender.com/";
  String link = "https://cause-api.vercel.app/";
  String link2 = "http://192.168.1.3:3000";
  String dist = "";
  if(selectedCourt == 0){
    dist = "madr";
  }
  else{
    dist = "mdu";
  }



  final response = await http.get(Uri.parse('https://causelistapi.onrender.com/data/$dist?date=$date&page=$page&limit=$limit'));

  print('https://causelistapi.onrender.com/data/$dist?date=$date&page=$page&limit=$limit');
  if (response.statusCode == 200) {
    print(jsonDecode(response.body));
    final jsonResponse = jsonDecode(response.body);
    
    return jsonResponse['data']; 
  } else {
    throw Exception('Failed to load cases');
  }
}
Future<List<dynamic>> fetchCasesAdvPresent(BuildContext context, {int page = 1, int limit = 20}) async {
  final advName = AppState().advName;
  final date = Provider.of<AppState>(context, listen: false).mainDate;
  final selectedCourt = Provider.of<AppState>(context, listen: false).selected_court;
  String dist = selectedCourt == 0 ? "madr" : "mdu";
  
  final response = await http.get(Uri.parse('https://causelistapi.onrender.com/dataoa/$advName/$dist?date=$date'));

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    print(jsonResponse);
    return jsonResponse['cases']; // Returns list of cases
  } else if (response.statusCode == 404) {
    final jsonResponse = jsonDecode(response.body);
    String errorMessage = jsonResponse['message'] ?? 'No cases found for advocate: $advName';
    
    // Fluttertoast.showToast(msg: errorMessage); // Display error message
    return []; // Return an empty list to indicate no cases found
  } else {
    throw Exception('Failed to load cases');
  }
}
Future<Map<String, List<dynamic>>> fetchCourts(BuildContext context, ) async {
  final selectedCourt = Provider.of<AppState>(context, listen: false).selected_court;
  final date = Provider.of<AppState>(context, listen: false).mainDate;
  String dist = "";
  if(selectedCourt == 0){
    dist = "madr";
  }
  else{
    dist = "mdu";
  }
  final response = await http.get(Uri.parse('https://causelistapi.onrender.com/courts/$dist?date=$date'));

  if (response.statusCode == 200) {
    print("Courts Fetching");
    final jsonResponse = jsonDecode(response.body);
    
    // Access the "CList" key
    final courtsMap = jsonResponse["CList"];  // This should be of type Map<String, dynamic>

    // Ensure the structure is as expected and cast to Map<String, List<dynamic>>
    if (courtsMap is Map<String, dynamic>) {
      // Create a new map to hold the formatted data
      Map<String, List<dynamic>> formattedCourtsMap = {};

      courtsMap.forEach((courtNumber, courtData) {
        // Ensure courtData is a list
        if (courtData is List) {
          formattedCourtsMap[courtNumber] = courtData; // Add to the formatted map
        } else {
          print('Warning: courtData for $courtNumber is not a list. Got: ${courtData.runtimeType}');
        }
      });

      return formattedCourtsMap; // Return the formatted map
    } else {
      throw Exception('Unexpected data format: ${courtsMap.runtimeType}');
    }
  } else {
    throw Exception('Failed to load courts');
  }
}





Future<List<dynamic>> fetchKeys() async {
  final response = await http.get(Uri.parse('https://causelistapi.onrender.com/keys'));

  if (response.statusCode == 200) {
    print(jsonDecode(response.body));
    final jsonResponse = jsonDecode(response.body);

    return jsonResponse; 
  } else {
    throw Exception('Failed to load cases');
  }
}

  

