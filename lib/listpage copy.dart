// import 'package:fincauselist/Tools/adtools.dart';
// import 'package:fincauselist/main.dart';
// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'ApiStuff.dart'; // Import your API fetching class

// class ListPage extends StatefulWidget {
//   const ListPage({Key? key}) : super(key: key);

//   @override
//   _ListPageState createState() => _ListPageState();
// }

// class _ListPageState extends State<ListPage> {
//   final ScrollController _scrollController = ScrollController();

//   List<dynamic> cases = [];
//   bool isLoadingCourts = false;
//   List<dynamic> courts = [];
//   Map<String, List<dynamic>> courtswithjustice = {};
//   bool isLoading = false;
//   bool hasMore = true;
//   bool start = true;
//   int currentPage = 1;
//   final int limit = 20; // Number of items per page

//   // // Non-paginated navigation support (AppBar arrows)
//   // final List<GlobalKey> _courtHeaderKeys = [];
//   // List<String> _courtNumbers = [];
//   // List<double> _courtOffsets = [];
//   // int _currentCourtIndex = 0;

//   // // Smoothly scroll to a header by its index; handles not-yet-built targets
//   // Future<void> _scrollToHeaderIndex(int index) async {
//   //   if (index < 0 || index >= _courtNumbers.length) return;

//   //   // Try to get the context; if missing, nudge-scroll towards direction until built
//   //   const int maxTries = 30;
//   //   int tries = 0;
//   //   final bool forward = index > _currentCourtIndex;
//   //   final double viewport = _scrollController.position.viewportDimension;
//   //   print('NAV: request index=$index current=$_currentCourtIndex viewport=$viewport');

//   //   while (tries < maxTries) {
//   //     final ctx = _courtHeaderKeys.length > index ? _courtHeaderKeys[index].currentContext : null;
//   //     if (ctx != null) {
//   //       // Precisely align the header to appear below status bar + AppBar
//   //       final box = ctx.findRenderObject() as RenderBox?;
//   //       if (box != null) {
//   //         final double topInset = MediaQuery.of(context).padding.top + kToolbarHeight;
//   //         final key = _courtHeaderKeys[index];
//   //         final dy = box.localToGlobal(Offset.zero).dy + _scrollController.offset - topInset;
//   //         final target = dy.clamp(0.0, _scrollController.position.maxScrollExtent);
//   //         print('NAV: snapping to target=$target (computed from dy=$dy)');
//   //         await _animateAndVerifyTo(key, target, topInset, index);
//   //       }
//   //       return;
//   //     }

//   //     // Not built yet: aggressively nudge using jumpTo to force build further ahead
//   //     final double step = (viewport * 2.2) * (forward ? 1 : -1);
//   //     final double current = _scrollController.offset;
//   //     final double nextOffset = (current + step)
//   //         .clamp(0.0, _scrollController.position.maxScrollExtent);
//   //     if ((nextOffset - current).abs() < 1.0) {
//   //       // No more room to move
//   //       print('NAV: cannot move further (at extent).');
//   //       break;
//   //     }
//   //     print('NAV: nudge try#$tries -> step=$step nextOffset=$nextOffset (jump)');
//   //     _scrollController.jumpTo(nextOffset);
//   //     // Wait a frame for layout to settle
//   //     await Future<void>.delayed(const Duration(milliseconds: 16));
//   //     tries++;
//   //   }
//   //   print('NAV: failed to build target header for index=$index after $maxTries tries');
//   // }

//   // // Animate to a target offset, then verify the header is aligned; if not, correct it iteratively.
//   // Future<void> _animateAndVerifyTo(GlobalKey key, double target, double topInset, int index) async {
//   //   // First animation to computed target
//   //   await _scrollController.animateTo(
//   //     target,
//   //     duration: const Duration(milliseconds: 300),
//   //     curve: Curves.easeOutCubic,
//   //   );

//   //   // Up to 3 corrective passes if header not exactly aligned
//   //   const int maxCorrections = 3;
//   //   for (int attempt = 0; attempt < maxCorrections; attempt++) {
//   //     await Future<void>.delayed(const Duration(milliseconds: 16));
//   //     final ctx = key.currentContext;
//   //     final box = ctx?.findRenderObject() as RenderBox?;
//   //     if (box == null) break;
//   //     final headerTop = box.localToGlobal(Offset.zero).dy;
//   //     final double delta = headerTop - topInset;
//   //     print('NAV: verify attempt#$attempt headerTop=$headerTop topInset=$topInset delta=$delta');
//   //     if (delta.abs() <= 1.0) {
//   //       print('NAV: alignment OK for index=$index at offset=${_scrollController.offset}');
//   //       if (mounted) setState(() => _currentCourtIndex = index);
//   //       return;
//   //     }

//   //     final correctedTarget = (_scrollController.offset + delta)
//   //         .clamp(0.0, _scrollController.position.maxScrollExtent);
//   //     print('NAV: correction -> newTarget=$correctedTarget');
//   //     await _scrollController.animateTo(
//   //       correctedTarget,
//   //       duration: const Duration(milliseconds: 180),
//   //       curve: Curves.easeOut,
//   //     );
//   //   }
//   //   // Finalize index even if slightly off to keep UI consistent
//   //   if (mounted) setState(() => _currentCourtIndex = index);
//   // }

//   @override
//   void initState() {
//     super.initState();
//     if (start == true) {
//       print("Hooiiiiiiiiiii");
//       print(AppState().advName);
//       _fetchCourtsOnce();
//       start = false;
//     }
    
//     // Check if there are selected courts from AppState
//     final appState = AppState();
//     final selectedCourts = appState.selectedCourts;
    
//     if (selectedCourts.isNotEmpty) {
//       // Fetch court-specific data
//       _fetchCourtSpecificCases();
//     } else if (AppState().advName == "") {
//       _fetchPaginatedCases(true);
//       print("true adv all");
//     } else {
//       _fetchPaginatedCases(false);
//       print("false adv present");
//     }
    
//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels ==
//               _scrollController.position.maxScrollExtent &&
//           !isLoading) {
//         final appState = AppState();
//         final selectedCourts = appState.selectedCourts;
        
//         if (selectedCourts.isNotEmpty) {
//           // For court-specific searches, we don't implement pagination yet
//           // All courts data is fetched at once
//         } else if (AppState().advName == "") {
//           _fetchPaginatedCases(true);
//           print("true adv all");
//         } else {
//           _fetchPaginatedCases(false);
//           print("false adv present");
//         }
//       }

//       // Update current header index based on scroll (cheap: uses cached offsets)
//       // if (_courtOffsets.isNotEmpty) {
//       //   final offset = _scrollController.offset;
//       //   int idx = 0;
//       //   for (int i = 0; i < _courtOffsets.length; i++) {
//       //     if (offset >= _courtOffsets[i]) idx = i;
//       //   }
//       //   if (idx != _currentCourtIndex && mounted) {
//       //     setState(() {
//       //       _currentCourtIndex = idx;
//       //     });
//       //   }
//       // }
//     });
//   }

//   Future<void> _fetchPaginatedCases(bool advPresent) async {
//     if (hasMore && !isLoading) {
//       setState(() {
//         isLoading = true;
//       });

//       try {
//         List<dynamic> newCases = advPresent
//             ? await fetchCasesAllAdv(context, page: currentPage, limit: limit)
//             : await fetchCasesAdvPresent(context,
//                 page: currentPage, limit: limit);

//         if (mounted) {
//           setState(() {
//             if (newCases.isNotEmpty) {
//               final caseSet = cases.map((c) => c['case_number']).toSet();
//               newCases = newCases
//                   .where((c) => !caseSet.contains(c['case_number']))
//                   .toList();

//               if (newCases.isNotEmpty) {
//                 cases.addAll(newCases);
//                 currentPage++;
//               } else {
//                 hasMore = false;
//               }
//             } else {
//               hasMore = false;
//             }
//           });
//         }
//       } catch (error) {
//         if (mounted) {
//           setState(() {
//             print('Error fetching cases: $error');
//           });
//         }
//       } finally {
//         if (mounted) {
//           setState(() {
//             isLoading = false;
//           });
//         }
//       }
//     }
//   }

//   // Fetch cases for selected courts
//   Future<void> _fetchCourtSpecificCases() async {
//     final appState = AppState();
//     final selectedCourts = appState.selectedCourts;
    
//     if (selectedCourts.isEmpty) return;
    
//     setState(() {
//       isLoading = true;
//     });

//     try {
//       // Get advocate name if provided
//       final advocateName = appState.advName.trim().isEmpty ? null : appState.advName.trim();
      
//       List<dynamic> courtCases = await fetchCasesForCourts(
//         context, 
//         selectedCourts, 
//         advocateName: advocateName
//       );
      
//       if (mounted) {
//         setState(() {
//           cases = courtCases;
//           hasMore = false; // No pagination for court-specific searches
//         });
//       }
//     } catch (error) {
//       if (mounted) {
//         setState(() {
//           print('Error fetching court cases: $error');
//         });
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> _fetchCourtsOnce() async {
//     print("Hoelloo");
//     setState(() {
//       isLoadingCourts = true;
//     });

//     try {
//       Map<String, List<dynamic>> newCourts =
//           await fetchCourts(context); // Get the formatted courts map
//       if (mounted) {
//         setState(() {
//           courtswithjustice = newCourts; // Store the courts data
//         });
//       }
//     } catch (error) {
//       print('Error fetching courts in side future: $error');
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoadingCourts = false;
//         });
//       }
//     }
//   }

//   // Helper function to get court info with case-insensitive matching
//   List<dynamic>? _getCourtInfo(String courtNumber) {
//     // Try exact match first
//     if (courtswithjustice.containsKey(courtNumber)) {
//       return courtswithjustice[courtNumber];
//     }
    
//     // Try case-insensitive match
//     String lowerCourtNumber = courtNumber.toLowerCase();
//     for (var key in courtswithjustice.keys) {
//       if (key.toLowerCase() == lowerCourtNumber) {
//         return courtswithjustice[key];
//       }
//     }
    
//     return null;
//   }

//   // Function to group cases by court number and category
//   Map<String, Map<String, List<dynamic>>> _groupCasesByCourtAndCategory(
//       List<dynamic> cases) {
//     Map<String, Map<String, List<dynamic>>> groupedByCourtAndCategory = {};
//     print("📈Cases : ${cases} ");
//     for (var caseItem in cases) {
//       String courtNumber = caseItem['court NO.'] ?? 'Unknown Court';
//       String category = caseItem['category'] ?? 'Unknown Category';

//       // Initialize the court group if not already created
//       if (!groupedByCourtAndCategory.containsKey(courtNumber)) {
//         groupedByCourtAndCategory[courtNumber] = {};
//       }

//       // Initialize the category group within the court group if not already created
//       if (!groupedByCourtAndCategory[courtNumber]!.containsKey(category)) {
//         groupedByCourtAndCategory[courtNumber]![category] = [];
//       }

//       // Add case to the respective court and category
//       groupedByCourtAndCategory[courtNumber]![category]!.add(caseItem);
//     }
//   print(  "📈Grouped Cases : ${groupedByCourtAndCategory} ");
//     return groupedByCourtAndCategory;
//   }

//   @override
//   void dispose() {
//     _scrollController
//         .dispose(); // Dispose the controller when the widget is disposed
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Map<String, Map<String, List<dynamic>>> courts =
//         _groupCasesByCourtAndCategory(cases);

//     // // Determine if we are in non-paginated mode
//     // final appState = AppState();
//     // final bool nonPaginated = appState.selectedCourts.isNotEmpty || appState.advName.isNotEmpty;

//     // // Prepare header keys and cache offsets when in non-paginated mode
//     // if (nonPaginated) {
//     //   _courtNumbers = courts.keys.toList();
//     //   // Ensure key list size matches number of courts
//     //   while (_courtHeaderKeys.length < _courtNumbers.length) {
//     //     _courtHeaderKeys.add(GlobalKey());
//     //   }
//     //   if (_courtHeaderKeys.length > _courtNumbers.length) {
//     //     _courtHeaderKeys.removeRange(_courtNumbers.length, _courtHeaderKeys.length);
//     //   }

//     //   // Cache positions after layout
//     //   WidgetsBinding.instance.addPostFrameCallback((_) {
//     //     if (!mounted) return;
//     //     if (_courtHeaderKeys.isEmpty) return;
//     //     final List<double> newOffsets = [];
//     //     for (final key in _courtHeaderKeys) {
//     //       final box = key.currentContext?.findRenderObject() as RenderBox?;
//     //       if (box != null) {
//     //         final dy = box.localToGlobal(Offset.zero).dy + _scrollController.offset - kToolbarHeight;
//     //         newOffsets.add(dy);
//     //       }
//     //     }
//     //     // Only update state if offsets changed to avoid rebuild loops
//     //     if (newOffsets.length == _courtNumbers.length && newOffsets.toString() != _courtOffsets.toString()) {
//     //       setState(() {
//     //         _courtOffsets = newOffsets;
//     //       });
//     //     }
//     //   });
//     // } else {
//     //   if (_courtOffsets.isNotEmpty || _courtHeaderKeys.isNotEmpty || _courtNumbers.isNotEmpty) {
//     //     // Clear when switching back to paginated mode
//     //     _courtOffsets = [];
//     //     _courtNumbers = [];
//     //     _courtHeaderKeys.clear();
//     //     _currentCourtIndex = 0;
//     //   }
//     // }

//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('CAUSE LISTℹ', style: Tools.H3),
//           // actions: [
//           //   if (nonPaginated && _courtNumbers.isNotEmpty)
//           //     Row(
//           //       children: [
//           //         IconButton(
//           //           tooltip: 'Next court',
//           //           icon: const Icon(Icons.arrow_downward),
//           //           onPressed: (_currentCourtIndex < _courtNumbers.length - 1)
//           //               ? () async {
//           //                   final next = (_currentCourtIndex + 1).clamp(0, _courtNumbers.length - 1);
//           //                   await _scrollToHeaderIndex(next);
//           //                 }
//           //               : null,
//           //         ),
//           //         Padding(
//           //           padding: const EdgeInsets.symmetric(horizontal: 6.0),
//           //           child: Text(
//           //             '${(_currentCourtIndex + 1).clamp(1, _courtNumbers.length)}',
//           //             style: Tools.H3.copyWith(fontSize: 16),
//           //           ),
//           //         ),
//           //         IconButton(
//           //           tooltip: 'Previous court',
//           //           icon: const Icon(Icons.arrow_upward),
//           //           onPressed: (_currentCourtIndex > 0)
//           //               ? () async {
//           //                   final prev = (_currentCourtIndex - 1).clamp(0, _courtNumbers.length - 1);
//           //                   await _scrollToHeaderIndex(prev);
//           //                 }
//           //               : null,
//           //         ),
//           //       ],
//           //     ),
//           // ],
//         ),
//         body: Column(
//           children: [
//             Expanded(
//               child: courts.isEmpty
//                   ? !isLoading
//                       ? Center(
//                           child: Column(
//                             children: [
//                               Padding(
//                                 padding:
//                                     const EdgeInsets.fromLTRB(20, 20, 20, 50),
//                                 child: Center(
                                    
//                                     child: AppState().advName.isNotEmpty
//                                         ? Text(
//                                             'No cases found for advocate: ${AppState().advName}',
//                                             style:
//                                                 Tools.H2.copyWith(fontSize: 15),
//                                           )
//                                         : Text(
//                                             'No cases found for the given Details ${AppState().advName}',
//                                             style:
//                                                 Tools.H2.copyWith(fontSize: 15),
//                                           )),
//                               ),
//                             ],
//                           ),
//                         )
//                       : const SafeArea(
//                           child: Column(
//                             children: [
//                               Expanded(
//                                 child: Center(
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment
//                                         .center, // Center vertically
//                                     children: [
//                                       CircularProgressIndicator(),
//                                       SizedBox(
//                                           height:
//                                               20), // Add space between the two widgets
//                                       // RefreshableBannerAdWidget(),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         )
//                   : Column(
//                       children: [
//                         Expanded(
//                           child: ListView.builder(
//                             controller:
//                                 _scrollController, // Attach the scroll controller for pagination
//                             itemCount: courts.keys.length,
//                             itemBuilder: (context, courtIndex) {
//                               String courtNumber =
//                                   courts.keys.elementAt(courtIndex);
//                               Map<String, List<dynamic>> categories =
//                                   courts[courtNumber]!;
      
//                               return Column(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   Container(
//                                     // key: (nonPaginated && courtIndex < _courtHeaderKeys.length)
//                                     //     ? _courtHeaderKeys[courtIndex]
//                                     //     : null,
//                                     color:
//                                         const Color.fromARGB(255, 193, 222, 215),
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: Column(
//                                         children: [
//                                           Text(
//                                             courtNumber,
//                                             style: Tools.H3,
//                                             textAlign: TextAlign.center,
//                                           ),
//                                           Text(
//                                             '${_getCourtInfo(courtNumber)?.first['justices'].isNotEmpty == true ? _getCourtInfo(courtNumber)?.first['justices'][0] : 'No Justices Info'}\n'
//                                             '${(_getCourtInfo(courtNumber)?.first['justices'].length ?? 0) > 1 ? _getCourtInfo(courtNumber)?.first['justices'][1] : ''}',
//                                             style: Tools.H3.copyWith(
//                                               fontSize: 17,
//                                               color: const Color.fromARGB(
//                                                   255, 227, 119, 119),
//                                             ),
//                                             textAlign: TextAlign.center,
//                                           ),
//                                           Text(
//                                             '${_getCourtInfo(courtNumber)?.first['timing'] ?? 'No timing Info'}',
//                                             style:
//                                                 Tools.H3.copyWith(fontSize: 12),
//                                             textAlign: TextAlign.center,
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                   // Iterate over the categories in this court
//                                   for (var category in categories.keys)
//                                     Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.center,
//                                       children: [
//                                         Padding(
//                                           padding: const EdgeInsets.all(4.0),
//                                           child: Text(
//                                             category,
//                                             style: Tools.H3.copyWith(
//                                                 color: const Color.fromARGB(
//                                                     255, 182, 8, 8)),
//                                             textAlign: TextAlign.center,
//                                           ),
//                                         ),
//                                         // Wrap the DataTable in SingleChildScrollView for horizontal scrolling
//                                         SingleChildScrollView(
//                                           scrollDirection: Axis.horizontal,
//                                           child: DataTable(
//                                             dataRowMaxHeight: double.infinity,
//                                             // headingRowHeight: 0,
      
//                                             columnSpacing: 5,
//                                             columns: const [
//                                               DataColumn(label: Text('S.No')),
//                                               DataColumn(label: Text('Case No')),
//                                               DataColumn(label: Text('Parties')),
//                                               DataColumn(
//                                                   label: Text(
//                                                       'Petitioner Advocates')),
//                                               DataColumn(
//                                                   label: Text(
//                                                       'Respondent Advocates')),
//                                               // DataColumn(label: Text('Category')),
//                                               // DataColumn(label: Text('Justice')),
//                                             ],
//                                             rows: _buildDataRows(
//                                                 categories[category]!),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                 ],
//                               );
//                             },
//                           ),
//                         ),
//                         if (isLoading)
//                           const Padding(
//                             padding: EdgeInsets.all(8.0),
//                             child: CircularProgressIndicator(),
//                           ),
//                       ],
//                     ),
//             ),
//             Container(
//               color: Colors.grey[300],
//               height: 50,
//               child: Center(
//                 child: RefreshableBannerAdWidget(),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   // Function to build data rows for cases within a category
//   List<DataRow> _buildDataRows(List<dynamic> categoryCases) {
//     List<DataRow> rows = [];

//     for (var item in categoryCases) {
//       rows.add(
//         DataRow(
//           cells: [
//             DataCell(Text(
//                 style: Tools.H3.copyWith(fontSize: 14),
//                 item['serial_number'] ?? '')),
//             DataCell(Text(
//                 style: Tools.H3.copyWith(fontSize: 14),
//                 item['case_number'] ?? '')),
//             DataCell(ConstrainedBox(
//               constraints: BoxConstraints(maxWidth: 250),
//               child: Text(
//                   style: Tools.H3.copyWith(fontSize: 14),
//                   item['parties'] ?? '',
//                   overflow: TextOverflow.clip),
//             )),
//             DataCell(ConstrainedBox(
//                 constraints: BoxConstraints(maxWidth: 250),
//                 child: Text(
//                     style: Tools.H3.copyWith(fontSize: 14),
//                     item['petitioner_advocates'] ?? ''))),
//             DataCell(ConstrainedBox(
//                 constraints: BoxConstraints(maxWidth: 250),
//                 child: Text(
//                     style: Tools.H3.copyWith(fontSize: 14),
//                     item['respondent_advocates'] ?? ''))),
//             // DataCell(ConstrainedBox(
//             //     constraints: BoxConstraints(maxWidth: 150),
//             //     child: Text(item['category'] ?? '',style: Tools.H3.copyWith(fontSize: 14),))),
//             // DataCell(ConstrainedBox(
//             //     constraints: BoxConstraints(maxWidth: 250),
//             //     child: Text(style: Tools.H3.copyWith(fontSize: 14),"${item['Justice'][0]}\t${item['Justice'][1]}" ?? ''))),
//           ],
//         ),
//       );
//     }

//     return rows;
//   }
// }
