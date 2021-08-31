import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rapid/model/rapid_test.dart';
import 'package:rapid/screens/certificate_page.dart';
import 'package:rapid/services/location_service.dart';
import 'package:rapid/services/pdf_api.dart';
import 'package:rapid/services/pdf_certificate_api.dart';
import 'package:rapid/styling/styling_constants.dart';
import 'package:rapid/widgets/appbar_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class TestResult extends StatelessWidget {
  final DocumentSnapshot? testKitSnapshot;
  final RapidTest? testKit;
  final DocumentSnapshot userSnapshot;

  const TestResult(
      {Key? key,
      this.testKit,
      required this.userSnapshot,
      this.testKitSnapshot})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBarTestResults(context, userSnapshot['testKitUID']),
      body: (testKitSnapshot == null
              ? testKit!.label == 'positive'
              : testKitSnapshot!['label'] == 'positive')
          ? _buildResultScreeen(context, true)
          : _buildResultScreeen(context, false),
    );
  }

  Widget _buildResultScreeen(BuildContext context, bool isPositive) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          _buildImage(isPositive),
          SizedBox(
            height: 80,
          ),
          _buildNotification(context, isPositive),
          SizedBox(
            height: 80,
          ),
          _buildGenerateButtonCertificate(
              context, userSnapshot, testKitSnapshot, testKit, isPositive),
          _buildSearchPCRTestButton(context, userSnapshot, isPositive),
        ],
      ),
    );
  }

  Widget _buildImage(bool isPositive) {
    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: Ink.image(
          image: (isPositive)
              ? AssetImage('assets/positive.jpg')
              : AssetImage('assets/negative.png'),
          fit: BoxFit.cover,
          width: 300,
          height: 300,
        ),
      ),
    );
  }

  Widget _buildNotification(BuildContext context, bool isPositive) {
    return Padding(
      padding: EdgeInsets.fromLTRB(42.0, 0.0, 42.0, 0.0),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: (isPositive)
              ? "Your rapid Antigen test came out positive, please see a doctor for proper PCR testing."
              : "Your rapid Antigen test came out negative! Generate your certificate with the button below",
          style: StylingConstants().inputTextTextStyle(),
        ),
      ),
    );
  }

  Widget _buildGenerateButtonCertificate(
      BuildContext context,
      DocumentSnapshot currentUserSnapshot,
      DocumentSnapshot? testKitSnapshot,
      RapidTest? testKit,
      bool isPositive) {
    return Visibility(
      visible: !isPositive,
      child: Container(
        child: Column(
          children: [
            SizedBox(
              width: 311,
              height: 40,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: StylingConstants().greenButtonColorEnabled,
                  elevation: StylingConstants().buttonElevation,
                ),
                onPressed: () async {
                  String fileName = (testKit == null)
                      ? testKitSnapshot!['testKitUID']
                      : testKit.testKitUID;

                  final pdfFile = await PdfCertificateApi.generate(
                      currentUserSnapshot, testKit, testKitSnapshot, fileName);

                  await PdfApi.openFile(pdfFile).whenComplete(
                    () => completeTest(context, fileName),
                  );
                },
                child: Text(
                  (isPositive) ? 'Seach for PCR Tests' : 'Generate Certificate',
                  style: StylingConstants().buttonTextTextStyle(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchPCRTestButton(BuildContext context,
      DocumentSnapshot currentUserSnapshot, bool isPositive) {
    return Visibility(
      visible: isPositive,
      child: Container(
        child: Column(
          children: [
            SizedBox(
              width: 311,
              height: 40,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: StylingConstants().greenButtonColorEnabled,
                  elevation: StylingConstants().buttonElevation,
                ),
                onPressed: () async {
                  PCRTestService().isPermissionGranted();
                  PCRTestService().isServiceEnabled();

                  double? longitude = await PCRTestService().getLongitude();
                  double? latitude = await PCRTestService().getLatitude();
                  print(longitude);
                  print(latitude);

                  launchURL(latitude!, longitude!);
                },
                child: Text(
                  (isPositive) ? 'Seach for PCR Tests' : 'Generate Certificate',
                  style: StylingConstants().buttonTextTextStyle(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void launchURL(double latitude, double longitude) async {
  final String googleSearchURL =
      "https://www.google.com/maps/search/PCR+Test/@$latitude,$longitude,13z/data=!3m1!4b1";

  final String encodedURl = Uri.encodeFull(googleSearchURL);

  if (await canLaunch(encodedURl)) {
    await launch(encodedURl);
  } else {
    throw 'Could not launch $encodedURl';
  }
}

void navigateToCertificatePage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => CertificatePage()),
  );
}
