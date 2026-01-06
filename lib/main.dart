import 'package:fincauselist/Tools/adtools.dart';
import 'package:fincauselist/dependency_injection.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';
import 'package:share_plus/share_plus.dart';
import 'package:fincauselist/listpage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fincauselist/about.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Modules/FeedBack/feedback_diaog.dart';
import 'Tools/app_update.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      // statusBarColor: Colors.blueGrey,
      // statusBarBrightness: Brightness.dark,
      // statusBarIconBrightness: Brightness.dark,
      // systemNavigationBarColor: Colors.blueGrey,
      // systemNavigationBarIconBrightness: Brightness.dark,
      // systemNavigationBarDividerColor: Colors.blueGrey,
      // systemNavigationBarContrastEnforced: false,
      // systemStatusBarContrastEnforced: false,
      // systemStatusBarContrastEnforced: false,
      // systemStatusBarContrastEnforced: false,

      ));

  checkForUpdate();
  runApp(ChangeNotifierProvider(
      create: (context) => AppState(), child: const MyApp()));
  DependencyInjection.init();
}

class AppState extends ChangeNotifier {
  static final AppState _singleton = AppState._internal();

  factory AppState() {
    return _singleton;
  }
  AppState._internal();
  static const court = ["Madras", "Madurai"];

  String mainDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  // String adv_name = "";

  int selected_court = 0;

  String advName = "";
  List<String> selectedCourts = [];

  void changeAdvName(String name) {
    advName = name;
    print("Changed Adv name");
    notifyListeners();
  }

  void updateSelectedCourts(List<String> courts) {
    selectedCourts = courts;
    notifyListeners();
  }

  void selected(int initial) {
    selected_court = initial;

    notifyListeners();
  }

  void updateMainDate(DateTime pickedDate) {
    mainDate = DateFormat('yyyy-MM-dd')
        .format(pickedDate); // Format pickedDate as string
    notifyListeners();
  }

  void toggleSelected() {
    AdManager().showInterstitialAd();
    if (selected_court == 0) {
      selected_court = 1;
    } else {
      selected_court = 0;
    }
    notifyListeners();
  }
}

class Tools {
  static const TextStyle H1 = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    fontFamily: 'H1',
  );

  static const TextStyle H2 = TextStyle(
    fontSize: 27,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    fontFamily: 'H1',
  );
  static const TextStyle H3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    fontFamily: 'H1',
  );

  static buttonStyle(bool isButtonActive) {
    return TextButton.styleFrom(
      foregroundColor: isButtonActive ? Colors.black : Colors.grey[600],
      backgroundColor: isButtonActive ? Colors.grey[200] : Colors.grey[300],
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  static const advlist = ["Velmurugan", "Murugan"];
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Display(),
    );
  }
}

class Display extends StatelessWidget {
  const Display({super.key});

  @override
  Widget build(BuildContext context) {
    return const CenterPage();
  }
}

class CenterPage extends StatefulWidget {
  const CenterPage({super.key});

  @override
  State<StatefulWidget> createState() => _CenterPage();
}

enum menuitems { about, share, exit, feedBack }

class _CenterPage extends State<CenterPage> with TickerProviderStateMixin {
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  bool isChecked1 = false;
  bool isChecked2 = false;
  DateTime? selectedDate;

  Timer? _adTimer;

  bool isbuttonactive = false;
  bool isdateactive = false;
  bool iscourtselectionactive = false;
  List<String> selectedCourts = [];
  List<String> availableCourts = [];

  bool firsttimeselect = true;

  late TextEditingController _controller;
  @override
  void initState() {
    super.initState();

    AdManager().loadInterstitialAd();

    // Optional: Show ad once after 10 seconds
    Timer(Duration(seconds: 10), () {
      AdManager().showInterstitialAd();
    });

    // Then show every 4 minutes
    _adTimer = Timer.periodic(Duration(minutes: 4), (timer) {
      AdManager().showInterstitialAd();
    });

    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    _interstitialAd?.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged1(bool? value) {
    final appState = Provider.of<AppState>(context, listen: false);
    if (value == true || (!isChecked2)) {
      setState(() {
        isChecked1 = value!;
        isChecked2 = !value;
        isbuttonactive = true;
        selectedCourts.clear(); // Clear courts when district changes
        appState.updateSelectedCourts([]); // Update AppState as well
        if (firsttimeselect == false) {
          appState.toggleSelected();
        } else {
          appState.selected(0);
          firsttimeselect = false;
        }
      });
    }
  }

  void _onChanged2(bool? value) {
    final appState = Provider.of<AppState>(context, listen: false);
    if (value == true || (!isChecked1)) {
      setState(() {
        isChecked2 = value!;
        isChecked1 = !value;
        isbuttonactive = true;
        selectedCourts.clear(); // Clear courts when district changes
        appState.updateSelectedCourts([]); // Update AppState as well
        if (firsttimeselect == false) {
          appState.toggleSelected();
        } else {
          appState.selected(1);
          firsttimeselect = false;
        }
      });
    }
  }

  // Show court selection dialog
  void _showCourtSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _CourtSelectionDialog(
          selectedCourts: selectedCourts,
          onCourtsSelected: (courts) {
            setState(() {
              selectedCourts = courts;
            });
            final appState = Provider.of<AppState>(context, listen: false);
            appState.updateSelectedCourts(courts);
          },
          onLoadCourts: _loadAvailableCourts,
        );
      },
    );
  }

  // Load available courts when dialog opens
  Future<List<String>> _loadAvailableCourts() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final selectedCourt = appState.selected_court;
    final date = appState.mainDate;
    
    String dist = selectedCourt == 0 ? "madr" : "mdu";
    String mainlink = "https://mhc.idealadvisories.com/apitest/";
    
    final response = await http.get(Uri.parse('${mainlink}keys/$dist?date=$date'));
    
    if (response.statusCode == 200) {
      final List<dynamic> courtsList = jsonDecode(response.body);
      
      List<String> processedCourts = [];
      
      for (var court in courtsList) {
        String courtStr = court.toString();
        
        // Handle numeric courts with possible subdivisions (e.g., "COURT NO. 03 a")
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
        
        // Handle special chambers (e.g., "csnj chambers", "skrj chambers a")
        RegExp chambersRegex = RegExp(r'([a-zA-Z]+(?:\s*[a-zA-Z]*)?)\s*chambers', caseSensitive: false);
        Match? chambersMatch = chambersRegex.firstMatch(courtStr);
        
        if (chambersMatch != null) {
          String chambersName = chambersMatch.group(1)!.trim().toLowerCase();
          processedCourts.add('$chambersName chambers');
          continue;
        }
      }
      
      // Remove duplicates and sort
      processedCourts = processedCourts.toSet().toList();
      processedCourts.sort((a, b) {
        // Sort numeric courts first, then chambers
        bool aIsNumeric = RegExp(r'^\d+(?:\s*[a-zA-Z])?$').hasMatch(a);
        bool bIsNumeric = RegExp(r'^\d+(?:\s*[a-zA-Z])?$').hasMatch(b);
        
        if (aIsNumeric && bIsNumeric) {
          // Extract numeric part for comparison
          int aNum = int.parse(RegExp(r'^(\d+)').firstMatch(a)!.group(1)!);
          int bNum = int.parse(RegExp(r'^(\d+)').firstMatch(b)!.group(1)!);
          if (aNum != bNum) return aNum.compareTo(bNum);
          return a.compareTo(b); // For subdivisions like "3 a" vs "3 b"
        } else if (aIsNumeric) {
          return -1;
        } else if (bIsNumeric) {
          return 1;
        } else {
          return a.compareTo(b);
        }
      });
      
      return processedCourts;
    } else {
      throw Exception('Failed to load courts');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    List<int> daysOfWeek = [7, 6]; // Prevent weekends

    DateTime initialDate = selectedDate ?? DateTime.now();
    while (daysOfWeek.contains(initialDate.weekday)) {
      initialDate = initialDate.add(Duration(days: 1));
    }

    Future.delayed(Duration.zero, () {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: "Date Picker",
        transitionDuration: Duration(milliseconds: 250), // Smooth animation
        pageBuilder: (context, anim1, anim2) {
          return FadeTransition(
            opacity: anim1,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(anim1),
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: _buildDatePicker(context, initialDate, daysOfWeek),
                ),
              ),
            ),
          );
        },
        transitionBuilder: (context, anim1, anim2, child) {
          return FadeTransition(
            opacity: anim1,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(anim1),
              child: child,
            ),
          );
        },
      );
    });
  }

// Separate function to create a date picker widget
  Widget _buildDatePicker(
      BuildContext context, DateTime initialDate, List<int> daysOfWeek) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Select Date",
                  style: Tools.H2.copyWith(color: Colors.white),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
          // Calendar
          Padding(
            padding: const EdgeInsets.all(15),
            child: Material(
              color: Colors.white,

              textStyle: Tools.H1.copyWith(fontSize: 18),
              

              child: CalendarDatePicker(
                initialDate: initialDate,

                firstDate: DateTime.now().subtract(Duration(days: 20)),
                lastDate: DateTime.now().add(Duration(days: 10)),
                selectableDayPredicate: (DateTime dateTime) =>
                    !daysOfWeek.contains(dateTime.weekday),
                onDateChanged: (pickedDate) {
                  Navigator.of(context)
                      .pop(); // Close dialog when a date is selected
                  if (pickedDate != selectedDate) {
                    Provider.of<AppState>(context, listen: false)
                        .updateMainDate(pickedDate);
                    selectedDate = pickedDate;
                    isdateactive = true;
                    selectedCourts.clear(); // Clear previous court selections
                    iscourtselectionactive = true; // Enable court selection
                    setState(() {}); // Refresh UI
                  }
                },
              ),
            ),
          ),
          // Footer with note
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(13),
                bottomRight: Radius.circular(13),
              ),
            ),
            child: Text(
              "Note: Weekends are excluded (Court holidays)",
              style: Tools.H3.copyWith(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final appState = Provider.of<AppState>(context);
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   statusBarColor:
    //       const Color.fromARGB(255, 0, 0, 0), // Change status bar background
    //   statusBarIconBrightness: Brightness.light, // Light text/icons
    // ));

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              Opacity(
                opacity: 0.3,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        isbuttonactive
                            ? isChecked1
                                ? 'assets/madras.jpg'
                                : 'assets/madurai.jpg'
                            : 'assets/madras.jpg',
                      ),
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "CAUSELIST",
                                  style: Tools.H1,
                                ),
                                PopupMenuButton<menuitems>(
                                  surfaceTintColor: Colors.white,
                                  popUpAnimationStyle: AnimationStyle(
                                      curve: Curves.easeInOut,
                                      duration: Duration(milliseconds: 300)),
                                  icon: const Icon(Icons.settings),
                                  color: Colors.white,
                                  itemBuilder: (BuildContext context) => [
                                    const PopupMenuItem(
                                      value: menuitems.about,
                                      child: Text("About"),
                                    ),
                                    const PopupMenuItem(
                                      value: menuitems.feedBack,
                                      child: Text("Feedback"),
                                    ),
                                    const PopupMenuItem(
                                      value: menuitems.share,
                                      child: Text("Share"),
                                    ),
                                    const PopupMenuItem(
                                      value: menuitems.exit,
                                      child: Text("Exit"),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    switch (value) {
                                      case menuitems.about:
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const AboutPage()));
                                        break;
                                      case menuitems.share:
                                        Share.share(
                                            "Checkout this app! https://play.google.com/store/apps/details?id=mhc.file.mhcdb&hl=en_IN",
                                            subject: "Look what I found!");
                                        break;
                                      case menuitems.feedBack:
                                        FeedbackDialog.show(context);
                                        break;
                                      case menuitems.exit:
                                        SystemNavigator.pop();
                                        break;
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                            child: Container(
                              width: double.maxFinite,
                              color: Colors.black,
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Center(
                                  child: Text(
                                    "Madras High Court",
                                    style:
                                        Tools.H2.copyWith(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: CheckboxListTile(
                                        title: const Text(
                                          "Madras",
                                          style: Tools.H3,
                                        ),
                                        value: isChecked1,
                                        checkColor: Colors.black,
                                        activeColor: Colors.transparent,
                                        onChanged: _onChanged1,
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                      ),
                                    ),
                                    Expanded(
                                      child: CheckboxListTile(
                                        checkColor: Colors.black,
                                        activeColor: Colors.transparent,
                                        title: const Text(
                                          "Madurai",
                                          style: Tools.H3,
                                        ),
                                        value: isChecked2,
                                        onChanged: _onChanged2,
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                AnimatedOpacity(
                                  curve: Curves.ease,
                                  opacity: isbuttonactive ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 600),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Text(
                                          "Select Date:",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: isbuttonactive
                                                ? Colors.black
                                                : const Color.fromARGB(
                                                    255, 192, 192, 192),
                                            fontFamily: 'H1',
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: isbuttonactive
                                              ? () => _selectDate(context)
                                              : null,
                                          style: TextButton.styleFrom(
                                            foregroundColor: isbuttonactive
                                                ? Colors.black
                                                : Colors.grey[600],
                                            backgroundColor: isbuttonactive
                                                ? Colors.grey[200]
                                                : Colors.grey[300],
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 17, vertical: 10),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                          ),
                                          child: Text(
                                            selectedDate != null
                                                ? DateFormat('dd/MM/yyyy')
                                                    .format(selectedDate!)
                                                : "Choose Date",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: isbuttonactive
                                                  ? Colors.black
                                                  : const Color.fromARGB(
                                                      255, 192, 192, 192),
                                              fontFamily: 'H1',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                // Search by Court button
                                AnimatedOpacity(
                                  curve: Curves.ease,
                                  opacity: iscourtselectionactive ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 500),
                                  child: iscourtselectionactive
                                      ? Padding(
                                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              Text(
                                                "Court👑:",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: iscourtselectionactive ? Colors.black : Colors.grey[600],
                                                  fontFamily: 'H1',
                                                ),
                                              ),
                                              Spacer(),
                                              TextButton(
                                                onPressed: iscourtselectionactive ? _showCourtSelectionDialog : null,
                                                style: TextButton.styleFrom(
                                                  foregroundColor: iscourtselectionactive ? Colors.black : Colors.grey[600],
                                                  backgroundColor: iscourtselectionactive ? Colors.grey[200] : Colors.grey[300],
                                                  padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
                                                ),
                                                child: Text(
                                                  selectedCourts.isEmpty
                                                      ? "All Courts"
                                                      : "${selectedCourts.length} Court${selectedCourts.length > 1 ? 's' : ''}",
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: iscourtselectionactive ? Colors.black : Colors.grey[600],
                                                    fontFamily: 'H1',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(),
                                ),
                                const SizedBox(height: 20),
                                AnimatedOpacity(
                                  curve: Curves.ease,
                                  opacity: isdateactive ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 500),
                                  child: isdateactive
                                      ? Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              30, 0, 20, 0),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Flexible(
                                                    flex: 1,
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        "Advocate:",
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: isdateactive
                                                              ? Colors.black
                                                              : const Color
                                                                  .fromARGB(
                                                                  255,
                                                                  192,
                                                                  192,
                                                                  192),
                                                          fontFamily: 'H1',
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Flexible(
                                                    flex: 1,
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: TextFormField(
                                                        controller: _controller,
                                                        onChanged:
                                                            (String value) {
                                                          final appstate =
                                                              Provider.of<
                                                                      AppState>(
                                                                  context,
                                                                  listen:
                                                                      false);
                                                          appstate
                                                              .changeAdvName(
                                                                  value);
                                                        },
                                                        decoration:
                                                            const InputDecoration(
                                                          hintText:
                                                              "Advocate Name",
                                                          border:
                                                              OutlineInputBorder(),
                                                          fillColor:
                                                              Colors.white,
                                                          filled: true,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(20.0),
                                                    child: CustomButton(selectedCourts: selectedCourts),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  RefreshableBannerAdWidget(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomButton extends StatefulWidget {
  final List<String> selectedCourts;
  
  const CustomButton({super.key, this.selectedCourts = const []});

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool isClicked = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (!isClicked) {
          setState(() {
            isClicked = true;
          });

          // Update AppState with selected courts
          final appState = Provider.of<AppState>(context, listen: false);
          appState.updateSelectedCourts(widget.selectedCourts);

          Fluttertoast.showToast(
            msg: 'Cause List Loading!',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: const Color.fromARGB(255, 213, 213, 213),
            textColor: Colors.black,
          );

          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => const ListPage()))
              .then((_) {
            // Reset button state when returning from ListPage
            if (mounted) {
              setState(() {
                isClicked = false;
              });
            }
          });
        }
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      child: Text(
        "Cause List!",
        style: Tools.H3.copyWith(color: Colors.white),
      ),
    );
  }
}

class AdvSrh extends StatefulWidget {
  const AdvSrh({super.key});

  @override
  State<AdvSrh> createState() => _AdvSrhState();
}

class _AdvSrhState extends State<AdvSrh> {
  final List<String> advocateList = [
    "Murugan",
    "VelMurugan",
    "simon",
    "Abcde",
    "Kavin",
    "Murugan",
    "VelMurugan",
    "simon",
    "Abcde",
    "Kavin",
  ];

  List<String> filteredList = [];

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredList = advocateList;

    final appState = Provider.of<AppState>(context, listen: false);
    _controller.text = appState.advName;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _filterAdvocates(String query) {
    setState(() {
      filteredList = advocateList
          .where((advocate) =>
              advocate.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _selectAdvocate(String advocate) {
    setState(() {
      _controller.text = advocate;
    });
    final appState = Provider.of<AppState>(context, listen: false);
    appState.changeAdvName(advocate);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Center(
        child: Card(
          elevation: 50,
          shadowColor: Colors.black,
          child: SizedBox(
            height: 500,
            width: 300,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    "Select\nAdvocate",
                    style: Tools.H3,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Search advocate',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _controller.clear();
                                _filterAdvocates('');
                                final appState = Provider.of<AppState>(context,
                                    listen: false);
                                appState.changeAdvName('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onChanged: (value) {
                      _filterAdvocates(value);
                    },
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(filteredList[index]),
                          onTap: () {
                            _selectAdvocate(filteredList[index]);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CourtSelectionDialog extends StatefulWidget {
  final List<String> selectedCourts;
  final Function(List<String>) onCourtsSelected;
  final Future<List<String>> Function() onLoadCourts;

  const _CourtSelectionDialog({
    required this.selectedCourts,
    required this.onCourtsSelected,
    required this.onLoadCourts,
  });

  @override
  State<_CourtSelectionDialog> createState() => _CourtSelectionDialogState();
}

class _CourtSelectionDialogState extends State<_CourtSelectionDialog> {
  List<String> _selectedCourts = [];
  List<String>? _availableCourts;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedCourts = List.from(widget.selectedCourts);
    _loadCourts();
  }

  Future<void> _loadCourts() async {
    try {
      final courts = await widget.onLoadCourts();
      if (mounted) {
        setState(() {
          _availableCourts = courts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _toggleCourtSelection(String court) {
    setState(() {
      if (_selectedCourts.contains(court)) {
        _selectedCourts.remove(court);
      } else {
        _selectedCourts.add(court);
      }
    });
  }

  String _formatCourtDisplay(String court) {
    // Handle judge courts (court 0)
    if (court == '0') {
      return 'Judge Chambers';
    }
    
    // Handle special chambers
    if (court.toLowerCase().contains('chambers')) {
      return court.toUpperCase();
    }
    
    // Handle numeric courts (with possible subdivisions)
    if (RegExp(r'^\d+(?:\s*[a-zA-Z])?$').hasMatch(court)) {
      return 'Court No. $court'.toUpperCase();
    }
    
    // Default formatting
    return court.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Select Courts",
                    style: Tools.H2.copyWith(color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            // Court list
            Flexible(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: _isLoading
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Colors.black,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Loading courts...",
                              style: Tools.H3,
                            ),
                          ],
                        ),
                      )
                    : _errorMessage != null
                        ? Center(
                            child: Text(
                              "Error loading courts: $_errorMessage",
                              style: Tools.H3.copyWith(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : _availableCourts == null || _availableCourts!.isEmpty
                            ? const Center(
                                child: Text(
                                  "No courts available for this date",
                                  style: Tools.H3,
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: _availableCourts!.length,
                                itemBuilder: (context, index) {
                                  final court = _availableCourts![index];
                                  final isSelected = _selectedCourts.contains(court);
                                  
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.grey[200] : Colors.white,
                                      border: Border.all(
                                        color: isSelected ? Colors.black : Colors.grey[300]!,
                                        width: isSelected ? 2 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        _formatCourtDisplay(court),
                                        style: Tools.H3.copyWith(
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                      trailing: isSelected
                                          ? const Icon(Icons.check, color: Colors.black)
                                          : null,
                                      onTap: () => _toggleCourtSelection(court),
                                    ),
                                  );
                                },
                              ),
              ),
            ),
            // Footer with buttons
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${_selectedCourts.length} selected",
                    style: Tools.H3.copyWith(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _selectedCourts.isNotEmpty
                        ? () {
                            widget.onCourtsSelected(_selectedCourts);
                            Navigator.of(context).pop();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("OK"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
