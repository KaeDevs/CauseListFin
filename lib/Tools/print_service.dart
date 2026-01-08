import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class PrintService {
  static Future<void> exportCasesAsPdf({
    required List<dynamic> cases,
    required Map<String, List<dynamic>> courtsInfo,
    String? title,
    String? fileName,
  }) async {
    final doc = pw.Document();

    final grouped = _groupCasesByCourtAndCategory(cases);

    final headerTitle = title ?? 'CAUSE LIST';

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 6),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                headerTitle,
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                _formatDateTime(),
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          padding: const pw.EdgeInsets.only(top: 6),
          child: pw.Text(
            'MHC Cause List App • Page ${context.pageNumber}/${context.pagesCount}',
            style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ),
        build: (context) {
          return _buildCourtWidgets(grouped, courtsInfo);
        },
      ),
    );

    final bytes = await doc.save();
    final name = fileName ?? 'cause_list_${DateTime.now().toIso8601String()}.pdf';

    // Share the generated PDF (allows saving or printing depending on platform)
    await Printing.sharePdf(bytes: bytes, filename: name);
  }

  static String _formatDateTime() {
    final dt = DateTime.now();
    return '${dt.year}-${_two(dt.month)}-${_two(dt.day)} ${_two(dt.hour)}:${_two(dt.minute)}';
  }

  static String _two(int v) => v.toString().padLeft(2, '0');

  // Grouping logic mimics the UI behaviour in ListPage
  static Map<String, Map<String, List<dynamic>>> _groupCasesByCourtAndCategory(
      List<dynamic> cases) {
    final Map<String, Map<String, List<dynamic>>> grouped = {};
    for (final caseItem in cases) {
      final String courtNumber = (caseItem['court NO.'] ?? 'Unknown Court').toString();
      final String category = (caseItem['category'] ?? 'Unknown Category').toString();

      grouped.putIfAbsent(courtNumber, () => <String, List<dynamic>>{});
      grouped[courtNumber]!.putIfAbsent(category, () => <dynamic>[]);
      grouped[courtNumber]![category]!.add(caseItem);
    }
    return grouped;
  }

  static List<pw.Widget> _buildCourtWidgets(
    Map<String, Map<String, List<dynamic>>> grouped,
    Map<String, List<dynamic>> courtsInfo,
  ) {
    final List<pw.Widget> widgets = [];

    grouped.forEach((courtNumber, categories) {
      widgets.add(
        pw.Container(
          color: PdfColors.lightBlue100,
          padding: const pw.EdgeInsets.all(8),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(courtNumber, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 2),
              _buildCourtJustices(courtsInfo, courtNumber),
              pw.SizedBox(height: 2),
              _buildCourtTiming(courtsInfo, courtNumber),
            ],
          ),
        ),
      );

      categories.forEach((category, items) {
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            child: pw.Text(
              category,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 12, color: PdfColors.red700, fontWeight: pw.FontWeight.bold),
            ),
          ),
        );

        widgets.add(_buildCategoryTable(items));
      });

      widgets.add(pw.SizedBox(height: 8));
    });

    return widgets;
  }

  static pw.Widget _buildCourtJustices(
      Map<String, List<dynamic>> courtsInfo, String courtNumber) {
    final info = _getCourtInfo(courtsInfo, courtNumber);
    String line1 = 'No Justices Info';
    String line2 = '';

    if (info != null && info.isNotEmpty) {
      final justices = info.first['justices'];
      if (justices is List && justices.isNotEmpty) {
        line1 = justices[0]?.toString() ?? line1;
        if (justices.length > 1) {
          line2 = justices[1]?.toString() ?? '';
        }
      }
    }

    return pw.Column(
      children: [
        pw.Text(line1, style: pw.TextStyle(fontSize: 11, color: PdfColors.red300)),
        if (line2.isNotEmpty)
          pw.Text(line2, style: pw.TextStyle(fontSize: 11, color: PdfColors.red300)),
      ],
    );
  }

  static pw.Widget _buildCourtTiming(
      Map<String, List<dynamic>> courtsInfo, String courtNumber) {
    final info = _getCourtInfo(courtsInfo, courtNumber);
    final timing = info != null && info.isNotEmpty ? info.first['timing']?.toString() ?? 'No timing Info' : 'No timing Info';
    return pw.Text(timing, style: const pw.TextStyle(fontSize: 9));
  }

  static List<dynamic>? _getCourtInfo(
      Map<String, List<dynamic>> courtsInfo, String courtNumber) {
    if (courtsInfo.containsKey(courtNumber)) {
      return courtsInfo[courtNumber];
    }
    final lowerCourtNumber = courtNumber.toLowerCase();
    for (final key in courtsInfo.keys) {
      if (key.toLowerCase() == lowerCourtNumber) {
        return courtsInfo[key];
      }
    }
    return null;
  }

  static pw.Widget _buildCategoryTable(List<dynamic> items) {
    final headerStyle = pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold);
    final cellStyle = const pw.TextStyle(fontSize: 9);

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FixedColumnWidth(35), // S.No
        1: const pw.FixedColumnWidth(80), // Case No
        2: const pw.FlexColumnWidth(2.6), // Parties
        3: const pw.FlexColumnWidth(2.2), // Petitioner Advocates
        4: const pw.FlexColumnWidth(2.2), // Respondent Advocates
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('S.No', style: headerStyle)),
            pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Case No', style: headerStyle)),
            pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Parties', style: headerStyle)),
            pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Petitioner Advocates', style: headerStyle)),
            pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Respondent Advocates', style: headerStyle)),
          ],
        ),
        ...items.map<pw.TableRow>((item) {
          final serial = (item['serial_number'] ?? '').toString();
          final caseNo = (item['case_number'] ?? '').toString();
          final parties = (item['parties'] ?? '').toString();
          final petAdv = (item['petitioner_advocates'] ?? '').toString();
          final resAdv = (item['respondent_advocates'] ?? '').toString();

          return pw.TableRow(
            children: [
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(serial, style: cellStyle)),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(caseNo, style: cellStyle)),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(parties, style: cellStyle)),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(petAdv, style: cellStyle)),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(resAdv, style: cellStyle)),
            ],
          );
        }).toList(),
      ],
    );
  }
}
