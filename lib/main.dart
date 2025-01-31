import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';
import 'package:share_plus/share_plus.dart';
import 'package:fincauselist/ApiStuff.dart';
import 'package:fincauselist/listpage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fincauselist/about.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(ChangeNotifierProvider(
      create: (context) => AppState(), child: const MyApp()));
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

  void changeAdvName(String name) {
    advName = name;
    print("Changed Adv name");
    notifyListeners();
  }

  void selected(int initial) {
    selected_court = initial;

    notifyListeners();
  }

  void updateMainDate(DateTime pickedDate) {
    mainDate = DateFormat('yyyy-MM-dd').format(pickedDate); // Format pickedDate as string
    notifyListeners();
  }

  void toggleSelected() {
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
    return MaterialApp(
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

enum menuitems { about, share, exit }

class _CenterPage extends State<CenterPage> with TickerProviderStateMixin {
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  bool isChecked1 = false;
  bool isChecked2 = false;
  DateTime? selectedDate;

  bool isbuttonactive = false;
  bool isdateactive = false;

  bool firsttimeselect = true;

  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();
  }

  @override
  void dispose() {
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
        if (firsttimeselect == false) {
          appState.toggleSelected();
        } else {
          appState.selected(1);
          firsttimeselect = false;
        }
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: selectedDate ?? DateTime.now(),
    firstDate: DateTime(2024, 12, 1),
    lastDate: DateTime(2025, 1, 31),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.dark().copyWith(
          primaryColor: Colors.black,
          hintColor: const Color.fromARGB(88, 212, 211, 211),
          colorScheme: const ColorScheme.light(primary: Colors.black),
          buttonTheme: const ButtonThemeData(
            textTheme: ButtonTextTheme.accent,
          ),
          dialogTheme: const DialogTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, 
            ),
          ),
        ),
        child: child!,
      );
    },
  );


    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        Provider.of<AppState>(context, listen: false).updateMainDate(pickedDate);
        
        selectedDate = pickedDate;
        isdateactive = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
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
                                icon: const Icon(Icons.settings),
                                itemBuilder: (BuildContext context) => [
                                  const PopupMenuItem(
                                    value: menuitems.about,
                                    child: Text("About"),
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
                                    Share.share("Checkout this app! https://play.google.com/store/apps/details?id=mhc.file.mhcdb&hl=en_IN", subject: "Look what I found!");
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
                                  style: Tools.H2.copyWith(color: Colors.white),
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
                                                                .fromARGB(255,
                                                                192, 192, 192),
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
                                                      onChanged: (String value) {
                                                        final appstate =
                                                            Provider.of<
                                                                    AppState>(
                                                                context,
                                                                listen: false);
                                                        appstate.changeAdvName(
                                                            value);
                                                      } ,
                                                      
                                                      decoration:
                                                          const InputDecoration(
                                                        hintText:
                                                            "Advocate Name",
                                                        border:
                                                            OutlineInputBorder(),
                                                        fillColor: Colors.white,
                                                        filled: true,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.all(20.0),
                                                  child: CustomButton(),
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
    );
  }
}

class CustomButton extends StatelessWidget {
  const CustomButton({super.key});

  @override
  Widget build(BuildContext context) {
    var isClicked = false;
    late Timer timer;
    startTimer() {
      timer = Timer(Duration(milliseconds: 1000), () => isClicked = false);
    }

    return ElevatedButton(
      onPressed: () {
        if (isClicked == false) {
          startTimer();
          isClicked = true;

          Fluttertoast.showToast(
            msg: 'Cause List Loading!',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: const Color.fromARGB(255, 213, 213, 213),
            textColor: Colors.black,
          );
        }
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const ListPage()));
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
    return Center(
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
                              final appState =
                                  Provider.of<AppState>(context, listen: false);
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
    );
  }
}


class RefreshableBannerAdWidget extends StatefulWidget {
  @override
  _RefreshableBannerAdWidgetState createState() =>
      _RefreshableBannerAdWidgetState();
}

class _RefreshableBannerAdWidgetState extends State<RefreshableBannerAdWidget> {
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;
  Timer? _adRefreshTimer;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _startAdRefreshTimer();
  }

  void _startAdRefreshTimer() {
    _adRefreshTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      // Fluttertoast.showToast(msg: "Ad Refreshing");
      _loadBannerAd();
    });
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/9214589741',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('Ad failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _adRefreshTimer?.cancel();
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isAdLoaded
        ? Container(
            alignment: Alignment.center,
            width: _bannerAd.size.width.toDouble(),
            height: _bannerAd.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd),
          )
        : SizedBox(); // Optionally show a placeholder or loading widget here
  }
}

