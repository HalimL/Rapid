import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:rapid/model/certificate.dart';
import 'package:rapid/model/rapid_test.dart';
import 'package:rapid/services/pdf_api.dart';

class PdfCertificateApi {
  static Future<File> generate(DocumentSnapshot user, RapidTest? rapidTest,
      DocumentSnapshot? rapidTestSnapshot, String documentName) async {
    final pdf = pw.Document();

    Certificate currentCertificate = Certificate(
      firstName: user['firstName'],
      lastName: user['lastName'],
      userID: user['uid'],
      testID: (rapidTestSnapshot == null)
          ? rapidTest!.testKitUID!
          : rapidTestSnapshot['testKitUID'],
      created: (rapidTestSnapshot == null)
          ? rapidTest!.created!
          : rapidTestSnapshot['created'],
      result: (rapidTestSnapshot == null)
          ? rapidTest!.label!
          : rapidTestSnapshot['label'],
      expiringDate: (rapidTestSnapshot == null)
          ? DateTime.parse(rapidTest!.created!)
              .add(Duration(days: 1))
              .toString()
          : DateTime.parse(rapidTestSnapshot['created'])
              .add(Duration(days: 1))
              .toString(),
    );

    final data = [
      ['Vorname / First Name', currentCertificate.firstName],
      ['Nachname / Last Name', currentCertificate.lastName],
      ['Probeentnahme am/ Sampling at', currentCertificate.created],
      ['Gültig bis / Valid Thru', currentCertificate.expiringDate],
      ['Testergebnis / Result', currentCertificate.result.toUpperCase()],
      ['Test ID', currentCertificate.testID],
      ['Test-Methode / Test method', currentCertificate.testMethod],
    ];

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [
        buildHeader(),
        buildDescription(),
        buildTable(data),
        buildTextAndQRCode(
            currentCertificate.testID, currentCertificate.expiringDate)
      ],
    ));

    return await PdfApi.saveDocument(
        name: '$documentName.pdf', pdf: pdf, certificate: currentCertificate);
  }

  static pw.Widget buildHeader() => pw.Column(children: <pw.Widget>[
        pw.Center(
          child: pw.Text(
            'Rapid App Covid-19 Antigen Certificate',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.SizedBox(height: 60),
      ]);

  static pw.Widget buildDescription() => pw.Column(children: <pw.Widget>[
        pw.Text(
          'Befund zu Testung auf SARS-CoV-2 (COVID-19)\nReport forSARS-CoV-2 (COVID-19) analysis',
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 40)
      ]);

  static pw.Widget buildTable(List<List<dynamic>> data) => pw.Stack(children: [
        pw.Padding(
          padding: pw.EdgeInsets.fromLTRB(235, 176.9, 0, 0),
          child:
              pw.Container(height: 40, width: 246, color: PdfColors.green400),
        ),
        pw.Table.fromTextArray(
          headerCount: 0,
          tableWidth: pw.TableWidth.min,
          data: data,
          cellHeight: 40,
          cellStyle: pw.TextStyle(fontSize: 20),
        ),
      ]);

  static pw.Widget buildTextAndQRCode(String testID, String expiringDate) =>
      pw.Column(children: [
        pw.SizedBox(height: 60),
        pw.Center(
          child: pw.BarcodeWidget(
            barcode: pw.Barcode.qrCode(),
            data: testID,
            height: 140,
            width: 140,
          ),
        ),
        pw.SizedBox(height: 60),
        pw.Text(
          'Sie können diesen QR Code zum Nachweis bis einschießlich $expiringDate verwenden und zum Check-In in teilnehmenden Tracing-Apps vor Ort nutzen. Der QR Code enthält ihre persönlichen Daten sowie das Testergebnis. Achten Sie unbedingt darauf, dass Sie diesen QR Code nur berechtigten Personen zum Check-In oder zum Nachweis des Testergebnisses vorzeigen. Zerstören Sie dieses Dokument nach Ablauf der Güligkeit.',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.normal,
          ),
        ),
        pw.SizedBox(height: 40),
        pw.Text(
          'You can use this QR code to proof your test or to check-in until $expiringDate in participating tracing apps on site. The QR code contains your personal data and the test result. Please make sure you only show this QR code to authorized persons for check-in or to prove the test result. Destroy this document after expiration.',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.normal,
          ),
        ),
      ]);
}
