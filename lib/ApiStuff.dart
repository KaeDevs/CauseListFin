import 'package:fincauselist/Constants/constants.dart';
import 'package:fincauselist/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


Future<List<dynamic>> fetchCasesAllAdv(BuildContext context, {int page = 1, int limit = 20}) async {
  final selectedCourt = Provider.of<AppState>(context, listen: false).selected_court;
  final date = Provider.of<AppState>(context, listen: false).mainDate;
  // String oldlink = "https://causelistapi.onrender.com/";
  // String link = "https://cause-api.vercel.app/";
  // String link2 = "http://192.168.1.3:3000";
  String mainlink = Constants().mainLink;
  String dist = "";
  if(selectedCourt == 0){
    dist = "madr";
  }
  else{
    dist = "mdu";
  }



  final response = await http.get(Uri.parse('${mainlink}data/$dist?date=$date&page=$page&limit=$limit'));

  print('${mainlink}data/$dist?date=$date&page=$page&limit=$limit');
  if (response.statusCode == 200) {
    print(jsonDecode(response.body));
    final jsonResponse = jsonDecode(response.body);
    
    return jsonResponse['data']; 
  } else {
    throw Exception('Failed to load cases');
  }
}
Future<List<dynamic>> fetchCasesAdvPresent(BuildContext context, {int page = 1, int limit = 20}) async {
  String mainlink = Constants().mainLink;
  final advName = AppState().advName;
  final date = Provider.of<AppState>(context, listen: false).mainDate;
  final selectedCourt = Provider.of<AppState>(context, listen: false).selected_court;
  String dist = selectedCourt == 0 ? "madr" : "mdu";
  
  final response = await http.get(Uri.parse('${mainlink}dataoa/$advName/$dist?date=$date'));

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
  print("📈Fetching Courts Once");
  final selectedCourt = Provider.of<AppState>(context, listen: false).selected_court;
  final date = Provider.of<AppState>(context, listen: false).mainDate;
  String mainlink = Constants().mainLink;
  String dist = "";
  if(selectedCourt == 0){
    dist = "madr";
  }
  else{
    dist = "mdu";
  }
  print("📈${dist}");
  String uri = '${mainlink}courts/$dist?date=$date';
  print(  "📈${uri}");
  final response = await http.get(Uri.parse(uri));

  if (response.statusCode == 200) {
    print("Courts Fetching");
    final jsonResponse = jsonDecode(response.body);
    print("📈${jsonResponse}");
    // Access the "CList" key
    final courtsMap = jsonResponse["cList"];  // This should be of type Map<String, dynamic>

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
      print("📈${formattedCourtsMap}");

      return formattedCourtsMap; // Return the formatted map
    } else {
      throw Exception('Unexpected data format: ${courtsMap.runtimeType}');
    }
  } else {
    throw Exception('Failed to load courts');
  }
}





Future<List<dynamic>> fetchKeys() async {
  String mainlink = Constants().mainLink;
  final response = await http.get(Uri.parse('${mainlink}keys'));

  if (response.statusCode == 200) {
    print(jsonDecode(response.body));
    final jsonResponse = jsonDecode(response.body);

    return jsonResponse; 
  } else {
    throw Exception('Failed to load cases');
  }
}

// Fetch available courts for a specific date and district
Future<List<String>> fetchAvailableCourts(BuildContext context) async {
  final selectedCourt = Provider.of<AppState>(context, listen: false).selected_court;
  final date = Provider.of<AppState>(context, listen: false).mainDate;
  String mainlink = Constants().mainLink;
  String dist = selectedCourt == 0 ? "madr" : "mdu";
  
  final response = await http.get(Uri.parse('${mainlink}keys/$dist?date=$date'));
  
  if (response.statusCode == 200) {
    final List<dynamic> courtsList = jsonDecode(response.body);
    
    List<String> processedCourts = [];
    
    for (var court in courtsList) {
      String courtStr = court.toString();
      
      // Handle numeric courts with possible subdivisions
      RegExp numericCourtRegex = RegExp(r'COURT NO\. (\d+(?:\s*[a-zA-Z])?)(?:\s|$)', caseSensitive: false);
      Match? numericMatch = numericCourtRegex.firstMatch(courtStr);
      
      if (numericMatch != null) {
        String courtNumber = numericMatch.group(1)!.trim();
        processedCourts.add(courtNumber);
        continue;
      }
      
      // Handle judge chambers (convert to court 0)
      if (courtStr.toLowerCase().contains('justice') || 
          courtStr.toLowerCase().contains('judge')) {
        if (!processedCourts.contains('0')) {
          processedCourts.add('0');
        }
        continue;
      }
      
      // Handle special chambers
      RegExp chambersRegex = RegExp(r'([a-zA-Z]+(?:\s*[a-zA-Z]*)?)\s*chambers', caseSensitive: false);
      Match? chambersMatch = chambersRegex.firstMatch(courtStr);
      
      if (chambersMatch != null) {
        String chambersName = chambersMatch.group(1)!.trim().toLowerCase();
        processedCourts.add('$chambersName chambers');
        continue;
      }
    }
    
    return processedCourts.toSet().toList();
  } else {
    throw Exception('Failed to load courts');
  }
}

// Fetch cases for specific courts using new enhanced API
Future<List<dynamic>> fetchCasesForCourts(BuildContext context, List<String> courts, {String? advocateName}) async {
  final selectedCourt = Provider.of<AppState>(context, listen: false).selected_court;
  final date = Provider.of<AppState>(context, listen: false).mainDate;
  String mainlink = Constants().mainLink;
  String dist = selectedCourt == 0 ? "madr" : "mdu";
  
  try {
    // Prepare court numbers with proper encoding
    List<String> encodedCourts = courts.map((court) {
      // URL encode spaces and special characters
      return Uri.encodeComponent(court);
    }).toList();
    
    // Join courts with comma for multiple court selection
    String courtNumbers = encodedCourts.join(',');
    
    String url;
    if (advocateName != null && advocateName.trim().isNotEmpty) {
      // API call with advocate name and multiple courts
      url = '${mainlink}dataoa/$advocateName/$dist?date=$date&courtNumbers=$courtNumbers';
    } else {
      // API call with just court numbers (null advocate)
      url = '${mainlink}dataoa/null/$dist?date=$date&courtNumbers=$courtNumbers';
    }
    
    print('Fetching from: $url');
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['cases'] != null && jsonResponse['cases'] is List) {
        return jsonResponse['cases'];
      } else {
        return [];
      }
    } else if (response.statusCode == 404) {
      final jsonResponse = jsonDecode(response.body);
      String errorMessage = jsonResponse['message'] ?? 'No cases found for selected courts';
      print('No cases found: $errorMessage');
      return [];
    } else {
      throw Exception('Failed to load cases: HTTP ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching court cases: $e');
    throw Exception('Failed to load court cases: $e');
  }
}

  

