import 'package:fincauselist/Tools/adtools.dart';
import 'package:fincauselist/main.dart';
import 'package:flutter/material.dart';
import 'ApiStuff.dart'; // Import your API fetching class

class ListPage extends StatefulWidget {
  const ListPage({Key? key}) : super(key: key);

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final ScrollController _scrollController = ScrollController();

  List<dynamic> cases = [];
  bool isLoadingCourts = false;
  List<dynamic> courts = [];
  Map<String, List<dynamic>> courtswithjustice = {};
  bool isLoading = false;
  bool hasMore = true;
  bool start = true;
  int currentPage = 1;
  final int limit = 20; // Number of items per page

  @override
  void initState() {
    super.initState();
    if (start == true) {
      print("Hooiiiiiiiiiii");
      print(AppState().advName);
      _fetchCourtsOnce();
      start = false;
    }
    
    // Check if there are selected courts from AppState
    final appState = AppState();
    final selectedCourts = appState.selectedCourts;
    
    if (selectedCourts.isNotEmpty) {
      // Fetch court-specific data
      _fetchCourtSpecificCases();
    } else if (AppState().advName == "") {
      _fetchPaginatedCases(true);
      print("true adv all");
    } else {
      _fetchPaginatedCases(false);
      print("false adv present");
    }
    
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !isLoading) {
        final appState = AppState();
        final selectedCourts = appState.selectedCourts;
        
        if (selectedCourts.isNotEmpty) {
          // For court-specific searches, we don't implement pagination yet
          // All courts data is fetched at once
        } else if (AppState().advName == "") {
          _fetchPaginatedCases(true);
          print("true adv all");
        } else {
          _fetchPaginatedCases(false);
          print("false adv present");
        }
      }
    });
  }

  Future<void> _fetchPaginatedCases(bool advPresent) async {
    if (hasMore && !isLoading) {
      setState(() {
        isLoading = true;
      });

      try {
        List<dynamic> newCases = advPresent
            ? await fetchCasesAllAdv(context, page: currentPage, limit: limit)
            : await fetchCasesAdvPresent(context,
                page: currentPage, limit: limit);

        if (mounted) {
          setState(() {
            if (newCases.isNotEmpty) {
              final caseSet = cases.map((c) => c['case_number']).toSet();
              newCases = newCases
                  .where((c) => !caseSet.contains(c['case_number']))
                  .toList();

              if (newCases.isNotEmpty) {
                cases.addAll(newCases);
                currentPage++;
              } else {
                hasMore = false;
              }
            } else {
              hasMore = false;
            }
          });
        }
      } catch (error) {
        if (mounted) {
          setState(() {
            print('Error fetching cases: $error');
          });
        }
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  // Fetch cases for selected courts
  Future<void> _fetchCourtSpecificCases() async {
    final appState = AppState();
    final selectedCourts = appState.selectedCourts;
    
    if (selectedCourts.isEmpty) return;
    
    setState(() {
      isLoading = true;
    });

    try {
      // Get advocate name if provided
      final advocateName = appState.advName.trim().isEmpty ? null : appState.advName.trim();
      
      List<dynamic> courtCases = await fetchCasesForCourts(
        context, 
        selectedCourts, 
        advocateName: advocateName
      );
      
      if (mounted) {
        setState(() {
          cases = courtCases;
          hasMore = false; // No pagination for court-specific searches
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          print('Error fetching court cases: $error');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchCourtsOnce() async {
    print("Hoelloo");
    setState(() {
      isLoadingCourts = true;
    });

    try {
      Map<String, List<dynamic>> newCourts =
          await fetchCourts(context); // Get the formatted courts map
      if (mounted) {
        setState(() {
          courtswithjustice = newCourts; // Store the courts data
        });
      }
    } catch (error) {
      print('Error fetching courts in side future: $error');
    } finally {
      if (mounted) {
        setState(() {
          isLoadingCourts = false;
        });
      }
    }
  }

  // Helper function to get court info with case-insensitive matching
  List<dynamic>? _getCourtInfo(String courtNumber) {
    // Try exact match first
    if (courtswithjustice.containsKey(courtNumber)) {
      return courtswithjustice[courtNumber];
    }
    
    // Try case-insensitive match
    String lowerCourtNumber = courtNumber.toLowerCase();
    for (var key in courtswithjustice.keys) {
      if (key.toLowerCase() == lowerCourtNumber) {
        return courtswithjustice[key];
      }
    }
    
    return null;
  }

  // Function to group cases by court number and category
  Map<String, Map<String, List<dynamic>>> _groupCasesByCourtAndCategory(
      List<dynamic> cases) {
    Map<String, Map<String, List<dynamic>>> groupedByCourtAndCategory = {};
    print("📈Cases : ${cases} ");
    for (var caseItem in cases) {
      String courtNumber = caseItem['court NO.'] ?? 'Unknown Court';
      String category = caseItem['category'] ?? 'Unknown Category';

      // Initialize the court group if not already created
      if (!groupedByCourtAndCategory.containsKey(courtNumber)) {
        groupedByCourtAndCategory[courtNumber] = {};
      }

      // Initialize the category group within the court group if not already created
      if (!groupedByCourtAndCategory[courtNumber]!.containsKey(category)) {
        groupedByCourtAndCategory[courtNumber]![category] = [];
      }

      // Add case to the respective court and category
      groupedByCourtAndCategory[courtNumber]![category]!.add(caseItem);
    }
  print(  "📈Grouped Cases : ${groupedByCourtAndCategory} ");
    return groupedByCourtAndCategory;
  }

  @override
  void dispose() {
    _scrollController
        .dispose(); // Dispose the controller when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, Map<String, List<dynamic>>> courts =
        _groupCasesByCourtAndCategory(cases);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('CAUSE LISTℹ', style: Tools.H3),
        ),
        body: Column(
          children: [
            Expanded(
              child: courts.isEmpty
                  ? !isLoading
                      ? Center(
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 20, 20, 50),
                                child: Center(
                                    
                                    child: AppState().advName.isNotEmpty
                                        ? Text(
                                            'No cases found for advocate: ${AppState().advName}',
                                            style:
                                                Tools.H2.copyWith(fontSize: 15),
                                          )
                                        : Text(
                                            'No cases found for the given Details ${AppState().advName}',
                                            style:
                                                Tools.H2.copyWith(fontSize: 15),
                                          )),
                              ),
                            ],
                          ),
                        )
                      : const SafeArea(
                          child: Column(
                            children: [
                              Expanded(
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment
                                        .center, // Center vertically
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(
                                          height:
                                              20), // Add space between the two widgets
                                      // RefreshableBannerAdWidget(),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            controller:
                                _scrollController, // Attach the scroll controller for pagination
                            itemCount: courts.keys.length,
                            itemBuilder: (context, courtIndex) {
                              String courtNumber =
                                  courts.keys.elementAt(courtIndex);
                              Map<String, List<dynamic>> categories =
                                  courts[courtNumber]!;
      
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    color:
                                        const Color.fromARGB(255, 193, 222, 215),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            courtNumber,
                                            style: Tools.H3,
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            '${_getCourtInfo(courtNumber)?.first['justices'].isNotEmpty == true ? _getCourtInfo(courtNumber)?.first['justices'][0] : 'No Justices Info'}\n'
                                            '${(_getCourtInfo(courtNumber)?.first['justices'].length ?? 0) > 1 ? _getCourtInfo(courtNumber)?.first['justices'][1] : ''}',
                                            style: Tools.H3.copyWith(
                                              fontSize: 17,
                                              color: const Color.fromARGB(
                                                  255, 227, 119, 119),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            '${_getCourtInfo(courtNumber)?.first['timing'] ?? 'No timing Info'}',
                                            style:
                                                Tools.H3.copyWith(fontSize: 12),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Iterate over the categories in this court
                                  for (var category in categories.keys)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text(
                                            category,
                                            style: Tools.H3.copyWith(
                                                color: const Color.fromARGB(
                                                    255, 182, 8, 8)),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        // Wrap the DataTable in SingleChildScrollView for horizontal scrolling
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: DataTable(
                                            dataRowMaxHeight: double.infinity,
                                            // headingRowHeight: 0,
      
                                            columnSpacing: 5,
                                            columns: const [
                                              DataColumn(label: Text('S.No')),
                                              DataColumn(label: Text('Case No')),
                                              DataColumn(label: Text('Parties')),
                                              DataColumn(
                                                  label: Text(
                                                      'Petitioner Advocates')),
                                              DataColumn(
                                                  label: Text(
                                                      'Respondent Advocates')),
                                              // DataColumn(label: Text('Category')),
                                              // DataColumn(label: Text('Justice')),
                                            ],
                                            rows: _buildDataRows(
                                                categories[category]!),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                        if (isLoading)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                      ],
                    ),
            ),
            Container(
              color: Colors.grey[300],
              height: 50,
              child: Center(
                child: RefreshableBannerAdWidget(),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Function to build data rows for cases within a category
  List<DataRow> _buildDataRows(List<dynamic> categoryCases) {
    List<DataRow> rows = [];

    for (var item in categoryCases) {
      rows.add(
        DataRow(
          cells: [
            DataCell(Text(
                style: Tools.H3.copyWith(fontSize: 14),
                item['serial_number'] ?? '')),
            DataCell(Text(
                style: Tools.H3.copyWith(fontSize: 14),
                item['case_number'] ?? '')),
            DataCell(ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 250),
              child: Text(
                  style: Tools.H3.copyWith(fontSize: 14),
                  item['parties'] ?? '',
                  overflow: TextOverflow.clip),
            )),
            DataCell(ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 250),
                child: Text(
                    style: Tools.H3.copyWith(fontSize: 14),
                    item['petitioner_advocates'] ?? ''))),
            DataCell(ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 250),
                child: Text(
                    style: Tools.H3.copyWith(fontSize: 14),
                    item['respondent_advocates'] ?? ''))),
            // DataCell(ConstrainedBox(
            //     constraints: BoxConstraints(maxWidth: 150),
            //     child: Text(item['category'] ?? '',style: Tools.H3.copyWith(fontSize: 14),))),
            // DataCell(ConstrainedBox(
            //     constraints: BoxConstraints(maxWidth: 250),
            //     child: Text(style: Tools.H3.copyWith(fontSize: 14),"${item['Justice'][0]}\t${item['Justice'][1]}" ?? ''))),
          ],
        ),
      );
    }

    return rows;
  }
}
