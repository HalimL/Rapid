import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:rapid/widgets/card_shimmer_widget.dart';
import 'package:rapid/widgets/header_image_shimmer.dart';
import 'package:rapid/widgets/header_shimmer_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:rapid/repository/firestore_repo.dart';
import 'package:rapid/screens/profile_page.dart';
import 'package:provider/provider.dart';
import 'package:rapid/styling/styling_constants.dart';
import 'package:rapid/utils/utils.dart';
import 'package:rapid/widgets/profile_picture_widget.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  static DateTime currentTime = new DateTime.now().toLocal();
  final DateTime eveningTime = new DateTime.utc(DateTime.now().year,
          DateTime.now().month, DateTime.now().day, 14, 0, 0)
      .toLocal();

  late Stream<QuerySnapshot> _coronaCardsTilesStream;
  late Stream<DocumentSnapshot> _coronaInfoStream;
  late DocumentSnapshot _currentUserSnapshot;
  late DocumentSnapshot? currentUserSnapshot;

  Stream<QuerySnapshot> getCoronaTilesTitleStream() {
    return FireStoreRepo().getCoronaTilesTitle();
  }

  Stream<DocumentSnapshot> getCoronaInfoStream(String? bundesland) {
    return FireStoreRepo().getCoronaInfo(bundesland);
  }

  @override
  void initState() {
    super.initState();
    _coronaCardsTilesStream = getCoronaTilesTitleStream();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final headerHeight = MediaQuery.of(context).size.height * 0.4;

    return Consumer<QuerySnapshot?>(builder: (context, userSnapshot, child) {
      if (userSnapshot != null) {
        _currentUserSnapshot = userSnapshot.docs.single;

        _coronaInfoStream =
            (_currentUserSnapshot['isDeutschlandUpdates'] == true)
                ? getCoronaInfoStream('Deutschland')
                : getCoronaInfoStream(_currentUserSnapshot['bundesland']);
        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          body: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    height: headerHeight,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        alignment: Alignment.centerLeft,
                        image: AssetImage("assets/corona-mask.jpg"),
                      ),
                    ),
                    child:
                        _buildHeader(_currentUserSnapshot, _coronaInfoStream),
                  ),
                ],
              ),
              Expanded(child: _buildCoronaInfoCards(_coronaInfoStream)),
            ],
          ),
        );
      } else {
        return Scaffold(
          body: Column(
            children: [
              Stack(
                children: <Widget>[
                  buildHeaderImageShimmer(),
                  buildHeaderShimmer(),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Center(
                      child: buildCardShimmer(),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  Widget _buildHeader(DocumentSnapshot userSnapshot,
      Stream<DocumentSnapshot> coronaInfoStream) {
    return Column(
      children: <Widget>[
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(240.0, 60.0, 0.0, 0.0),
            child: ProfileWidget(
              onClicked: () => navigateToProfile(context),
              imagePath: userSnapshot['imagePath'],
              className: (HomePage).toString(),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 20.0, 10.0, 0.0),
            child: Text(
              currentTime.isBefore(eveningTime)
                  ? 'Good Day, \n${userSnapshot['firstName']}'
                  : 'Good Evening, \n${userSnapshot['firstName']}',
              style: StylingConstants().greetingsWhiteTextStyle(),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildHeaderShimmer() => Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 60.0, 40.0, 0.0),
                child: HeaderShimmerWidget.circle(
                  width: 96,
                  height: 96,
                )),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 20.0, 20.0, 0.0),
                child: HeaderShimmerWidget.title(width: 140, height: 20)),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 20.0, 100.0, 0.0),
                child: HeaderShimmerWidget.title(width: 60, height: 20)),
          ),
        ],
      );

  Widget buildHeaderImageShimmer() {
    final shimmerHeaderHeight = MediaQuery.of(context).size.height * 0.38;
    return HeaderImageShimmerWidget.header(
      width: double.infinity,
      height: shimmerHeaderHeight,
    );
  }

  Widget _buildCoronaInfoCards(Stream<DocumentSnapshot> coronaInfoStream) {
    DocumentSnapshot _coronaCardsTilesSnapshot;
    DocumentSnapshot _coronaInfoSnapshot;

    return StreamBuilder(
      stream: _coronaCardsTilesStream,
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot> titleStreamSnapshot) {
        return StreamBuilder(
          stream: coronaInfoStream,
          builder: (BuildContext context,
              AsyncSnapshot<DocumentSnapshot> coronaInfoStreamSnapshot) {
            if (titleStreamSnapshot.hasData &&
                coronaInfoStreamSnapshot.hasData) {
              return new ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: titleStreamSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  _coronaCardsTilesSnapshot =
                      titleStreamSnapshot.data!.docs[index];
                  _coronaInfoSnapshot = coronaInfoStreamSnapshot.data!;

                  return Center(
                    child: _buildListItem(
                        _coronaCardsTilesSnapshot, _coronaInfoSnapshot),
                  );
                },
              );
            } else {
              return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Center(
                      child: buildCardShimmer(),
                    );
                  });
            }
          },
        );
      },
    );
  }

  Widget _buildListItem(
      DocumentSnapshot coronaCardTile, DocumentSnapshot coronaInfo) {
    String searchField1 = coronaCardTile['searchKey'];
    String searchField2 = coronaCardTile['searchKey2'];

    Color color = (searchField2 == "previousLast7Days" ||
            searchField2 == "previousNewCases" ||
            searchField2 == "previousIncidenceScore")
        ? (coronaInfo[searchField2] == coronaInfo[searchField1])
            ? Colors.black
            : ((coronaInfo[searchField2] > coronaInfo[searchField1])
                ? Colors.green
                : Colors.red)
        : Colors.black;
    return Row(
      children: [
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          margin: const EdgeInsets.fromLTRB(14.0, 0.0, 14.0, 20.0),
          elevation: 8.0,
          shadowColor: Colors.grey.withOpacity(0.8),
          color: Colors.white,
          child: Stack(children: <Widget>[
            Container(
              height: 340,
              width: 320,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20.0, 30.0, 0.0, 0.0),
                        child: Text(
                          coronaCardTile['cardTitle'],
                          style: StylingConstants().containerTextStyleText(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 20.0, 0.0),
                        child: InkWell(
                          child: Icon(Icons.info_outline, color: Colors.blue),
                          onTap: () {
                            buildDescriptionDialog(context, coronaCardTile);
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(30.0, 20.0, 0.0, 0.0),
                        child: Text(
                          (searchField1 != "incidenceScore")
                              ? Utils().numberSeperator(
                                  coronaInfo[searchField1].toString(), 3)
                              : coronaInfo[searchField1]
                                  .toString()
                                  .split('.')
                                  .join(','),
                          style: StylingConstants()
                              .containerTextStyleNumbers(color),
                        ),
                      ),
                      Visibility(
                        visible: (searchField2 != ""),
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(10.0, 20.0, 0.0, 0.0),
                          child: (searchField2 == "previousLast7Days" ||
                                  searchField2 == "previousNewCases")
                              ? (Icon(
                                  (coronaInfo[searchField2] ==
                                          coronaInfo[searchField1])
                                      ? Icons.minimize
                                      : ((coronaInfo[searchField2] >
                                              coronaInfo[searchField1])
                                          ? Icons.arrow_downward_rounded
                                          : Icons.arrow_upward_rounded),
                                  size: 40,
                                  color: color,
                                ))
                              : ((searchField2 == "previousIncidenceScore")
                                  ? (Icon(
                                      (coronaInfo[searchField2] ==
                                              coronaInfo[searchField1])
                                          ? Icons.minimize
                                          : ((coronaInfo[searchField2] <
                                                  coronaInfo[searchField1])
                                              ? Icons.arrow_upward_rounded
                                              : Icons.arrow_downward_rounded),
                                      size: 40,
                                      color: color,
                                    ))
                                  : Scaffold()),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.all(10.0),
                    height: 180,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: (searchField1 == 'newCases')
                            ? AssetImage('assets/covid-19-newcases.png')
                            : (searchField1 == 'last7Days')
                                ? AssetImage('assets/covid-19-7days-cases.png')
                                : (searchField1 == 'totalCases')
                                    ? AssetImage('assets/total-cases.png')
                                    : (searchField1 == 'incidenceScore')
                                        ? AssetImage(
                                            'assets/cases_indizwert.png')
                                        : (searchField1 == 'totalDeaths')
                                            ? AssetImage(
                                                'assets/covid-virus.png')
                                            : AssetImage(
                                                'assets/rapid-testing.jpg'),
                        alignment: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ],
    );
  }

  Widget buildCardShimmer() => Card(
        margin: const EdgeInsets.fromLTRB(14.0, 10.0, 14.0, 20.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        child: CardShimmerWidget.card(
          width: 320,
          height: 340,
        ),
      );

  Future navigateToProfile(context) async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ProfilePage()));
  }

  buildDescriptionDialog(
      BuildContext context, DocumentSnapshot titlesSnapshot) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Container(
              height: 180,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding:
                              const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(CupertinoIcons.clear),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                    child: Text(
                      titlesSnapshot['description'],
                      style: StylingConstants().descriptionTextStyleText(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
