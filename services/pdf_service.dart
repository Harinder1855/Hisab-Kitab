import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/customer.dart';
import '../models/transaction.dart';
import 'database.dart'; // <--- Database import zaruri hai settings ke liye

class PdfService {
  static Future<void> generateReport({
    required Customer customer,
    required List<Transaction> transactions,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final pdf = pw.Document();
    
    // --- 🏢 BUSINESS DETAILS RETRIEVE ---
    final shopName = DatabaseService.settingsBox.get('shopName', defaultValue: "Hisab Kitab");
    final shopAddress = DatabaseService.settingsBox.get('shopAddress', defaultValue: "");
    final shopPhone = DatabaseService.settingsBox.get('shopPhone', defaultValue: "");

    final dateRangeText = fromDate != null && toDate != null
        ? "${DateFormat('dd/MM/yy').format(fromDate)} to ${DateFormat('dd/MM/yy').format(toDate)}"
        : "Full Transaction History";

    double totalGave = 0;
    double totalGot = 0;
    for (var t in transactions) {
      if (t.type == 'gave') totalGave += t.amount; else totalGot += t.amount;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // --- 🏗️ PROFESSIONAL BRANDED HEADER ---
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(shopName.toUpperCase(), 
                  style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.green900)),
              if (shopAddress.isNotEmpty) 
                pw.Text(shopAddress, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
              if (shopPhone.isNotEmpty) 
                pw.Text("Contact: $shopPhone", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
              pw.SizedBox(height: 5),
              pw.Divider(thickness: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("TRANSACTION STATEMENT", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
                  pw.Text("Date: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}", style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            ],
          ),
          
          pw.SizedBox(height: 20),

          // --- 👤 CUSTOMER INFO ---
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Report For:", style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                  pw.Text(customer.name, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text("Phone: ${customer.phone ?? 'N/A'}", style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text("Statement Period:", style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                  pw.Text(dateRangeText, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 20),

          // --- 💰 SUMMARY BOX ---
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _summaryItem("Total Gave (Dr)", "Rs ${totalGave.toStringAsFixed(2)}", PdfColors.red900),
                _summaryItem("Total Got (Cr)", "Rs ${totalGot.toStringAsFixed(2)}", PdfColors.green900),
                _summaryItem("Net Balance", "Rs ${(totalGave - totalGot).abs().toStringAsFixed(2)}", 
                    (totalGave - totalGot) >= 0 ? PdfColors.red900 : PdfColors.green900),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // --- 📊 TRANSACTIONS TABLE ---
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.green800),
            cellHeight: 25,
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerRight,
              3: pw.Alignment.centerRight,
            },
            headers: ['Date', 'Note', 'Gave (Dr)', 'Got (Cr)'],
data: transactions.map((t) => [
  DateFormat('dd/MM/yy').format(t.date),
  t.note ?? "-",
  // 🔥 Column color logic
  pw.Text(t.type == 'gave' ? t.amount.toStringAsFixed(2) : "", style: pw.TextStyle(color: PdfColors.red)),
  pw.Text(t.type == 'got' ? t.amount.toStringAsFixed(2) : "", style: pw.TextStyle(color: PdfColors.green)),
]).toList(),
          ),

          // --- 📝 FOOTER ---
          pw.SizedBox(height: 40),
          pw.Divider(thickness: 0.5, color: PdfColors.grey400),
          pw.Center(
            child: pw.Text("This is a computer-generated statement. Thank you for your business!", 
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  // Helper for Summary Items
  static pw.Widget _summaryItem(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 8)),
        pw.SizedBox(height: 4),
        pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: color)),
      ],
    );
  }
}