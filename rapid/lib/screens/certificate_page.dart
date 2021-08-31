import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rapid/repository/firestore_repo.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:rapid/services/pdf_api.dart';
import 'package:rapid/styling/styling_constants.dart';
import 'package:toggle_switch/toggle_switch.dart';

class CertificatePage extends StatefulWidget {
  CertificatePage({Key? key}) : super(key: key);

  @override
  _CertificatePageState createState() => _CertificatePageState();
}

class _CertificatePageState extends State<CertificatePage> {
  late DocumentSnapshot _currentUserSnapshot;
  late Stream<QuerySnapshot> _certificateStream;
  late int _initialIndex;

  Stream<QuerySnapshot> getCertificateStream(String userID, int index) {
    return FireStoreRepo().getCertificateStream(userID, index);
  }

  @override
  void initState() {
    _initialIndex = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _currentUserSnapshot = Provider.of<QuerySnapshot?>(context)!.docs.single;
    _certificateStream =
        getCertificateStream(_currentUserSnapshot['uid'], _initialIndex);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: <Widget>[
          _buildToggleSwitch(),
          SizedBox(
            height: 40,
          ),
          _buildCertificateStream(_certificateStream),
        ],
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
        child: ToggleSwitch(
          minWidth: 100.0,
          minHeight: 30,
          cornerRadius: 30.0,
          activeBgColors: [
            [const Color(0xfff7f5f7)],
            [const Color(0xfff7f5f7)]
          ],
          borderColor: [const Color(0xffe4e5eb)],
          borderWidth: 5,
          activeFgColor: Colors.green.shade700,
          inactiveBgColor: const Color(0xffe4e5eb),
          inactiveFgColor: const Color(0xff636f7b),
          initialLabelIndex: _initialIndex,
          totalSwitches: 2,
          labels: ['Active', 'Expired'],
          radiusStyle: true,
          onToggle: (index) {
            setState(() {
              _initialIndex = index;
              _certificateStream = getCertificateStream(
                  _currentUserSnapshot['uid'], _initialIndex);
            });
          },
        ),
      ),
    );
  }

  Widget _buildCertificateStream(Stream<QuerySnapshot> certificateStream) {
    return StreamBuilder(
        stream: certificateStream,
        builder: (_, AsyncSnapshot<QuerySnapshot> certificateSnapshot) {
          if (certificateSnapshot.hasData &&
              certificateSnapshot.data!.docs.isNotEmpty &&
              certificateSnapshot.connectionState == ConnectionState.active) {
            if (_initialIndex == 0 &&
                certificateSnapshot.data!.docs.length == 1) {
              return _buildSingleCertificatePDFView(
                  certificateSnapshot.data!.docs.single);
            } else if (_initialIndex == 1 &&
                certificateSnapshot.data!.docs.length >= 1) {
              return Expanded(
                child: _buildCertificateList(certificateSnapshot.data!),
              );
            } else {
              return Container();
            }
          } else if (!certificateSnapshot.hasData ||
              certificateSnapshot.data!.docs.isEmpty) {
            return _buildNoActiveCertificate();
          } else {
            return Column(
              children: <Widget>[
                SizedBox(
                  height: 200,
                ),
                CircularProgressIndicator(
                  color: Colors.green,
                ),
              ],
            );
          }
        });
  }

  Widget _buildCertificateList(QuerySnapshot listCertificateSnapshot) {
    late DocumentSnapshot _certificateSnapshot;

    return new ListView.separated(
      separatorBuilder: (context, index) => Divider(
        color: Colors.white,
        thickness: 1.5,
      ),
      itemCount: listCertificateSnapshot.docs.length,
      itemBuilder: (context, index) {
        _certificateSnapshot = listCertificateSnapshot.docs[index];

        return Center(
          child: _buildListItem(
            _certificateSnapshot,
          ),
        );
      },
    );
  }

  Widget _buildSingleCertificatePDFView(DocumentSnapshot certificateSnapshot) {
    String fileName = certificateSnapshot['certificateName'];
    return DelayedDisplay(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 100,
          ),
          InkWell(
            child: Column(
              children: [
                Card(
                  borderOnForeground: true,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  elevation: 10.0,
                  shadowColor: Colors.grey.withOpacity(0.8),
                  color: Colors.grey.shade200,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                    height: 200,
                    width: 180,
                    child: _buildImage('pdf.png', 70),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  '${fileName.characters.take(10).toString()}...${fileName.substring(19, fileName.length)}',
                  style: StylingConstants().subtitleTextTextStyle(),
                )
              ],
            ),
            onTap: () async {
              showCertificate(certificateSnapshot['certificateName']);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNoActiveCertificate() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 180,
        ),
        _buildImage('error.png', 70),
        SizedBox(
          height: 20,
        ),
        Text(
          'No certificate to show',
          style: StylingConstants().subtitleTextTextStyle(),
        )
      ],
    );
  }

  Widget _buildImage(String imageFile, double size) {
    return Material(
      color: Colors.transparent,
      child: Ink.image(
        image: AssetImage('assets/$imageFile'),
        fit: BoxFit.cover,
        width: size,
        height: size,
      ),
    );
  }

  Widget _buildListItem(DocumentSnapshot certificateSnapshot) {
    String fileName = certificateSnapshot['certificateName'];
    return new ListTile(
      tileColor: Colors.white,
      leading: _buildImage('pdf.png', 30),
      title: Text(
        '${fileName.characters.take(10).toString()}...${fileName.substring(19, fileName.length)}',
        softWrap: false,
        maxLines: 1,
        style: StylingConstants().subtitleTextTextStyle(),
      ),
      trailing: FittedBox(
        alignment: Alignment.bottomRight,
        fit: BoxFit.fill,
        child: Column(
          children: <Widget>[
            Text(
              certificateSnapshot['expiringDate']
                  .toString()
                  .characters
                  .take(11)
                  .toString(),
            ),
          ],
        ),
      ),
      onTap: () {
        showCertificate(certificateSnapshot['certificateName']);
      },
    );
  }
}

void showCertificate(String fileName) async {
  final dir = await getApplicationDocumentsDirectory();

  final file = File('${dir.path}/$fileName');

  PdfApi.openFile(file);
}
