import 'dart:typed_data';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:galaxy_store/config/global.dart';
import 'package:galaxy_store/controllers/delDetContainerController.dart';
import 'package:galaxy_store/controllers/delDetUpdateStatusController.dart';
import 'package:galaxy_store/controllers/deliverUpdateController.dart';
import 'package:galaxy_store/controllers/deliveryCount.dart';
import 'package:galaxy_store/controllers/driverController.dart';
import 'package:galaxy_store/controllers/batchController.dart';
import 'package:galaxy_store/controllers/shippingController.dart';
import 'package:galaxy_store/controllers/truckController.dart';
import 'package:galaxy_store/controllers/updateDelShipController.dart';
import 'package:galaxy_store/controllers/witnessController.dart';
import 'package:galaxy_store/controllers/witnessUpdateController.dart';
import 'package:galaxy_store/libraries/AudioPlay.dart';
import 'package:galaxy_store/libraries/MyHttpRequest.dart';
import 'package:galaxy_store/libraries/loading.dart';
import 'package:galaxy_store/models/batch.dart';
import 'package:galaxy_store/models/delDetContainer.dart';
import 'package:galaxy_store/models/delDetUpdateStatus.dart';
import 'package:galaxy_store/models/deliveryCount.dart';
import 'package:galaxy_store/models/deliveryUpdate.dart';
import 'package:galaxy_store/models/driver.dart';
import 'package:galaxy_store/models/shipping.dart';
import 'package:galaxy_store/models/shippingUpdate.dart';
import 'package:galaxy_store/models/truck.dart';
import 'package:galaxy_store/models/updateDelShip.dart';
import 'package:galaxy_store/models/witness.dart';
import 'package:galaxy_store/models/witnessUpdate.dart';
import 'package:galaxy_store/config/session.dart' as session;
import 'package:galaxy_store/pages/login/loginView.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:hand_signature/signature.dart';
import 'package:galaxy_store/models/issuingDelivery.dart';
import 'package:galaxy_store/controllers/issuingDeliveryController.dart';
import 'package:galaxy_store/models/detailsContType.dart';
import 'package:galaxy_store/controllers/detailsContTypeController.dart';
import 'package:galaxy_store/models/dropDown.dart';
import 'package:date_format/date_format.dart';
import 'package:vibration/vibration.dart';

class CheckingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Delivery Scanner',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: CheckingPage(),
    );
  }
}

const _kPages = <String, IconData>{
  'search': Icons.search,
  'unloading': Icons.done,
  'confirm': Icons.done_all,
};

class CheckingPage extends StatefulWidget {
  const CheckingPage({Key key}) : super(key: key);

  @override
  CheckingPageState createState() => CheckingPageState();
}

class CheckingPageState extends State<CheckingPage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> issuingScaffoldKey =
      GlobalKey<ScaffoldState>();
  AudioPlay scanPlayer = new AudioPlay();
  AudioPlay errorScanPlayer = new AudioPlay();
  String mp3Uri;
  Loading pr;
  bool get scrollTest => false;
  final pageTitle = TextEditingController();
  final navBarTitle = TextEditingController();

  // static final GlobalKey<ConvexAppBarState> appBarKeyIssuing =  new GlobalKey<ConvexAppBarState>();

  TabStyle _tabStyle = TabStyle.reactCircle;
  static TabController tabController;

  final _shippingFormKey = GlobalKey<FormState>();
  IssuingDeliveryReturn _issuingDeliveryReturn;
  DetailsContTypeReturn _detailsContTypeReturn;
  TruckReturn _truckReturn;
  DriverReturn _driverReturn;
  ShippingReturn _shippingReturn;
  ShippingUpdateReturn _shippingUpdateReturn;
  DeliveryUpdateReturn _deliveryUpdateReturn;
  DelDetUpdateStatusReturn delDetUpdateStatusReturn;
  WitnessReturn _witnessReturn;
  WitnessUpdateReturn _witnessUpdateReturn;
  BatchReturn _batchReturn;
  DelDetContainerReturn _delDetContainerReturn;
  List<DropdownMenuItem> _locationList = [];
  List<DropdownMenuItem> _truckList2 = [];
  List<DropdownMenuItem> _driverList2 = [];
  List<DropdownMenuItem> _batchList2 = [];
  List<dynamic> dosContents = [];
  List<DropDown> _batchList = [];
  List<DropDown> _truckList = [];
  List<DropDown> _driverList = [];
  final _issuingSearchFormKey = GlobalKey<FormState>();
  final _issuingScanningFormkey = GlobalKey<FormState>();
  final _confirmationFormKey = GlobalKey<FormState>();
  final _searchDate = TextEditingController();
  final _searchControlNo = TextEditingController();
  final _searchLocation = TextEditingController();
  final _searchIsLoaded = TextEditingController();
  final _searchLocationID = TextEditingController();

  final _scanningFormKey = GlobalKey<FormState>();
  final _searchZone = TextEditingController();
  final _searchBarcode = TextEditingController();
  final _selectedDeliverID = TextEditingController();

  final _selectedLocationCode = TextEditingController();
  final _selectedLocation = TextEditingController();
  final _selectedDONo = TextEditingController();
  final _selectedShippedDate = TextEditingController();
  final _selectedLocationID = TextEditingController();
  DateTime _selectedDate;
  final _selectedControlNo = TextEditingController();

  int totalContainer = 0;
  int totalScannedQty = 0;
  int totalLoadedQty = 0;
  int isComplete = 0;
  int totalUnloadedQty = 0;
  int totalOffLoadedQty = 0;

  final _selectedZone = TextEditingController();

  final _scanningBarcode = TextEditingController();
  final _scanningQty = TextEditingController();
  final _scanningZone = TextEditingController();
  final _scanningStatus = TextEditingController();
  final _scanningDeliverDetailID = TextEditingController();
  final _scanningTypeID = TextEditingController();
  final _scanningRemarks = TextEditingController();

  final _scanningTotalItemQty = TextEditingController();
  final _scanningLoadedQty = TextEditingController();
  final _scanningOffLoadedQty = TextEditingController();

  var _batchIndex = null;
  var _truckIndex = null;
  var _driverIndex = null;

  final _selectedTruck = TextEditingController();
  final _selectedDriver = TextEditingController();
  final _selectedBatchNo = TextEditingController();

  bool _isUpdating = false;
  bool _isContinueScanning = false;
  bool _isDisableQty = false;
  bool _isAllowedToShip = false;
  bool _isReceived = false;
  bool _isReceivedByBatch = false;
  bool _withWitness = false;
  bool _isOffloading = false;
  bool isSCan = false;

  final witness = TextEditingController();
  final notedBy = TextEditingController();
  DefaultCacheManager manager = new DefaultCacheManager();
  var focusNode = FocusNode();
  ValueNotifier<ByteData> signatureResult = ValueNotifier<ByteData>(null);
  HandSignatureControl control = new HandSignatureControl(
    threshold: 5.0,
    smoothRatio: 0.65,
    velocityRange: 2.0,
  );

  ValueNotifier<String> svg = ValueNotifier<String>(null);

  ValueNotifier<ByteData> rawImage = ValueNotifier<ByteData>(null);

  @override
  void initState() {
    super.initState();
    httpGetIssuingDelivery();
    navBarTitle.text = "SEARCH DELIVERY!";
    _selectedDeliverID.text = "";
    _searchLocation.text = "3210";
    _searchLocationID.text = "";
    _scanningStatus.text = "1";
    _selectedBatchNo.text = "1";
    _isReceivedByBatch = false;
    pageTitle.text = "SEARCH DELIVERY!";
    tabController = new TabController(
      vsync: this,
      length: _kPages.length,
    );
    tabController.addListener(() {
      setState(() {
        if (_isUpdating == false) {
          this._scanningBarcode.text = "";
          this._scanningZone.text = "";
          this._scanningQty.text = "";
          this._scanningStatus.text = "";
          _isContinueScanning = true;
        } else {
          _isContinueScanning = false;
        }
        switch (tabController.index) {
          case 0:
            {
              pageTitle.text = "SEARCH DELIVERY";
            }
            break;
          case 1:
            {
              pageTitle.text = "UNLOADING DETAILS";
              _isOffloading = false;
              if (_selectedDeliverID.text != "") {
                httpGetDeliveryCount();
                httpGetDelDetContainer();
              }
            }
            break;
          case 2:
            {
              pageTitle.text = "DRIVER CONFIRMATION";
              if (_selectedDeliverID.text != "") {
                imageCache.clear();
                rawImage.value = null;
                _isAllowedToShip = false;
                _isReceived = false;
                _isReceivedByBatch = false;
                _withWitness = true;
                witness.text = "";
                notedBy.text = "";
                _truckIndex = null;
                _driverIndex = null;
                _batchIndex = null;

                httpGetTruck();
                httpGetDriver();
                httpGetBatch();
                setState(() {
                  control.clear();
                });
              }
            }
            break;
        }
      });

      if (_selectedDeliverID.text == "" && tabController.index != 0) {
        GlobalDialog(
                context: context,
                title: "No Record",
                message: "Please search delivery first!",
                dismiss: 60)
            .showErrorDialog();
      }
    });

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        _scanningQty.selection = TextSelection(
            baseOffset: 0, extentOffset: _scanningQty.text.length);
      }
    });
    scanPlayer.load(soundsPath + scanAudioFile, scanAudioFile);
    errorScanPlayer.load(soundsPath + scanErrorAudioFile, scanErrorAudioFile);
  }

  @override
  Widget build(BuildContext context) {
    final drawerHeader = UserAccountsDrawerHeader(
      currentAccountPicture: Icon(
        Icons.verified_user,
        color: Colors.white,
        size: 50.0,
      ),
      accountName: session.userEmployeeID == 0
          ? Text("")
          : Text(
              '${session.userLocationCode} - ${session.userLocation}',
              // '$apiDDZoneUrl',
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
      accountEmail: session.userEmployeeID == 0
          ? Text("")
          : Text(
              session.userFullName,
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
    );
    final drawerItems = ListView(
      children: <Widget>[
        Container(height: 150, child: drawerHeader),
        session.userIsScanning == 3
            ? ListTile(
                leading: Icon(
                  Icons.list,
                  color: Colors.orangeAccent,
                ),
                title: Text(
                  'Store Delivery',
                  style: TextStyle(
                      color: Colors.orangeAccent, fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                })
            : Text(""),
        ListTile(
            title: Text(
              'Logout',
              style: TextStyle(color: Colors.orangeAccent),
            ),
            leading: Icon(Icons.exit_to_app, color: Colors.orangeAccent),
            onTap: () async {
              session.destroySession();
              Navigator.of(context).pop();
              Navigator.of(context).push(new PageRouteBuilder(
                  pageBuilder: (BuildContext context, _, __) {
                return new LoginView();
              }, transitionsBuilder:
                      (_, Animation<double> animation, __, Widget child) {
                return new FadeTransition(opacity: animation, child: child);
              }));
            }),
      ],
    );

    return DefaultTabController(
      length: _kPages.length,
      initialIndex: 0,
      child: Scaffold(
        key: issuingScaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            backgroundColor: Colors.orange,
            title: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _selectedDeliverID.text == ""
                    ? "SEARCH DELIVERY"
                    : "${_selectedLocation.text} : ${_selectedDONo.text} : ${_selectedShippedDate.text}",
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            )),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Row(
                children: <Widget>[
                  Text(
                    pageTitle.text,
                    style: new TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orangeAccent),
                  ),
                  tabController.index != 0
                      ? Text("")
                      : Expanded(
                          child: Align(
                            alignment: Alignment.topRight,
                            child: InkWell(
                              splashColor: Colors.orange,
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(30, 0, 30, 0),
                                child: Icon(
                                  Icons.search,
                                  color: Colors.orangeAccent,
                                ),
                              ),
                              onTap: () {
                                _searchDialog(context);
                              },
                            ),
                          ),
                        )
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Color.fromRGBO(247, 245, 237, 1),
                    border: Border.all(
                      color: Colors.white24,
                    )),
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: tabController,
                  children: [
                    _issuingDeliveryReturn == null
                        ? Center(child: Text('Loading..'))
                        : RefreshIndicator(
                            onRefresh: () async {
                              httpGetIssuingDelivery();
                            },
                            child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: SingleChildScrollView(
                                    child: Container(
                                        decoration: contentDecoration(),
                                        child: displayDeliverTab()))),
                          ),
                    _delDetContainerReturn == null
                        ? Center(child: Text('No record found!'))
                        : checkingContent(),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SingleChildScrollView(
                          child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: DropdownSearch<DropDown>(
                              items: _batchList,
                              itemAsString: (DropDown u) => u.name,
                              selectedItem: _batchIndex == null
                                  ? null
                                  : _batchList[_batchIndex],
                              maxHeight: 300,
                              label: "Batch No.",
                              onChanged: (e) {
                                setState(() {
                                  print(e.name);
                                  int c = 0;
                                  _batchList.forEach((element) {
                                    if (e.id == element.id) {
                                      _batchIndex = c;
                                    }
                                    c++;
                                  });
                                  _selectedBatchNo.text = e.id;
                                });
                                httpGetDetailsContType();
                                setTruckAndDriverVal(e.id);
                                httpGetWitness();
                              },
                              showSearchBox: true,
                            ),
                          ),
                          Container(
                              decoration: contentDecoration(),
                              child: displayConfirmationTab())
                        ],
                      )),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: ConvexAppBar(
          initialActiveIndex: 0,
          controller: tabController,
          backgroundColor: Colors.orange,
          style: TabStyle.reactCircle,
          items: <TabItem>[
            for (final entry in _kPages.entries)
              TabItem(icon: entry.value, title: entry.key),
          ],
          onTap: (int i) {
            setState(() {
              _isUpdating = false;
            });
          },
        ),
        drawer: Drawer(
          child: drawerItems,
        ),
      ),
    );
  }

  BoxDecoration contentDecoration() {
    return BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.grey,
        ));
  }

  Widget checkHeader() {
    return SizedBox(
      width: double.infinity,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              children: <Widget>[
                Text(
                  "$totalLoadedQty",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("Total LD"),
              ],
            ),
            SizedBox(
              width: 20,
            ),
            Column(
              children: <Widget>[
                Text(
                  "$totalUnloadedQty",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("Total UL"),
              ],
            ),
            SizedBox(
              width: 20,
            ),
            Column(
              children: <Widget>[
                Text(
                  "$totalOffLoadedQty",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("Total OL"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget checkingContent() {
    return RefreshIndicator(
      onRefresh: () async {
        httpGetDeliveryCount();
        httpGetDelDetContainer();
      },
      child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              checkHeader(),
              SizedBox(
                height: 20,
              ),
              Container(
                decoration: contentDecoration(),
                height: MediaQuery.of(context).size.height - 340,
                child: SingleChildScrollView(child: displayDetailsTab()),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: RaisedButton(
                      onPressed: isComplete == 1
                          ? null
                          : () async {
                              _scan(context);
                            },
                      color: Colors.green,
                      child: Text('Scan for Unload',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )
            ],
          )),
    );
  }

  Widget displayDeliverTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        DataTable(
          columnSpacing: 6,
          columns: [
            DataColumn(label: Text('Control No.')),
            DataColumn(label: Text('Total LD')),
            DataColumn(label: Text('Ship Date')),
          ],
          rows: _issuingDeliveryReturn.items
              .map((e) => DataRow(
                    cells: <DataCell>[
                      DataCell(
                          Text(
                            "${e["controlNo"]}",
                            style: new TextStyle(
                                color: Colors.orangeAccent,
                                fontWeight: FontWeight.bold),
                          ), onTap: () {
                        setState(() {
                          _selectedDeliverID.text = e["deliverID"];
                          _selectedDONo.text = "${e["controlNo"]}";
                          _selectedShippedDate.text =
                              "${formatDate(DateTime.parse(e["shippedDate"]), [
                                yyyy,
                                '-',
                                mm,
                                '-',
                                dd,
                              ])}";
                          _selectedLocationCode.text = "${e['locationCode']}";
                          _selectedLocation.text =
                              "${e['locationCode']} - ${e['location']}";
                        });
                        print(">>>>>>>> selected deliverID: ${e['deliverID']}");
                        tabController.animateTo(1,
                            duration: Duration(milliseconds: 1));
                      }),
                      DataCell(Text("${e["totalLoadedQty"]}")),
                      DataCell(Text(
                          "${e["shippedDate"] == null ? '' : formatDate(DateTime.parse(e["shippedDate"]), [
                                  yyyy,
                                  '-',
                                  mm,
                                  '-',
                                  dd,
                                  ' ',
                                  hh,
                                  ':',
                                  nn
                                ])}")),
                    ],
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget displayDetailsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AbsorbPointer(
            absorbing: tabController.index == 2, child: _containerTable())
      ],
    );
  }

  Widget _containerTable() {
    var count = 0;
    int allTotal = 0;
    int whTotal = 0;
    int ldTotal = 0;
    int ulTotal = 0;
    int olTotal = 0;

    List rows = [];
    rows.addAll(_delDetContainerReturn.items);
    rows.add({
      "container": "",
      "zone": "",
      "scannedQty": "",
      "loadedQty": "",
      "unloadedQty": "",
      "offloadedQty": ""
    });
    return DataTable(
      showCheckboxColumn: true,
      columnSpacing: 6,
      columns: [
        DataColumn(label: Text('')),
        DataColumn(label: Text('Container')),
        DataColumn(label: Text('Type')),
        DataColumn(label: Text('LD')),
        DataColumn(label: Text('UL')),
        DataColumn(label: Text('OL')),
      ],
      rows: _delDetContainerReturn.items.map((e) {
        count++;
        //if (count < rows.length) {
        whTotal += e["scannedQty"];
        ldTotal += e["loadedQty"];
        ulTotal += e["unloadedQty"];
        olTotal += e["offloadedQty"];
        return DataRow(
          cells: <DataCell>[
            DataCell(containerTableIcon(e)),
            DataCell(
                Text(
                  "${e["container"]}",
                  style: new TextStyle(
                      color: Colors.blueAccent, fontWeight: FontWeight.bold),
                ), onTap: () {
              setState(() {
                isSCan = false;
              });
              if (e["detailType_ID"] == 2) {
                _scanningBarcode.text = "${e["container"]}";
              } else {
                _scanningBarcode.text =
                    "${e["container"]}-${_selectedLocationCode.text}";
              }
              this._scanningDeliverDetailID.text = "${e["deliverDetail_ID"]}";
              if (e["unloadedQty"] != 0) {
                this._scanningQty.text = e["unloadedQty"].toString();
              }

              this._scanningTypeID.text = e["containerType_ID"].toString();
              _scanningRemarks.text = "${e["remUL"]}";
              if (_scanningBarcode.text
                      .contains(new RegExp('dos', caseSensitive: false)) ||
                  e["detailType_ID"] == 2) {
                if (e["unloadedQty"] != 0) {
                  this._scanningQty.text = e["unloadedQty"].toString();
                }
              } else {
                _scanningQty.text = "1";
              }

              if (_scanningBarcode.text
                  .contains(new RegExp('dos', caseSensitive: false))) {
                getDOSContent(e);
              } else {
                _containerFormDialog(
                    _delDetContainerReturn.items.indexOf(e), e, dosContents);
              }
            }),
            DataCell(Center(
                child: Container(
              color:
                  e["containerType_ID"] == 1 ? Colors.cyan : Colors.pinkAccent,
              child: Text(" ${e["contType"]} ",
                  style: TextStyle(color: Colors.white)),
            ))),
            DataCell(Center(child: Text("${e["loadedQty"]}"))),
            DataCell(Center(child: Text("${e["unloadedQty"]}"))),
            DataCell(Center(child: Text("${e["offloadedQty"]}"))),
          ],
        );
      }).toList(),
    );
  }

  Widget containerTableIcon(e) {
    var icon;

    bool isDisabledChecking = e["isReceived"] == 1 || e["loadedQty"] == 0;
    if (e["isChecked"] == 1) {
      icon = Icon(Icons.check_box,
          color: isDisabledChecking ? Colors.grey : Colors.green);
    } else {
      icon = Icon(Icons.crop_square,
          color: isDisabledChecking ? Colors.grey : Colors.green);
    }

    return Container(
      width: 50,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(1, 1, 20, 1),
        child: RawMaterialButton(
          onPressed: isDisabledChecking
              ? null
              : () {
                  setState(() {
                    isSCan = false;
                  });
                  check(e);
                },
          elevation: 2.0,
          fillColor: Colors.white,
          child: icon,
          padding: EdgeInsets.all(2.0),
          shape: CircleBorder(),
        ),
      ),
    );
  }

  void check(e) {
    setState(() {
      if (e["zones"] == '') {
        _scanningBarcode.text = "${e["container"]}";
      } else {
        _scanningBarcode.text =
            "${e["container"]}-${_selectedLocationCode.text}";
      }
      _scanningDeliverDetailID.text = "${e["deliverDetail_ID"]}";
      _scanningTypeID.text = e['containerType_ID'].toString();
      _scanningRemarks.text = "${e["remUL"]}";

      _scanningStatus.text = _isOffloading == true ? "3" : "1";
      if ((e["offloadedQty"] > 1 ||
              (_scanningBarcode.text
                      .contains(new RegExp('dos', caseSensitive: false)) ||
                  e["detailType_ID"] == 2)) &&
          e["isChecked"] != 1) {
        if (e["isChecked"] == 1) {
          _scanningQty.text = "0";
        } else {
          this._scanningQty.text = "";
        }
        if (_scanningBarcode.text
            .contains(new RegExp('dos', caseSensitive: false))) {
          getDOSContent(e);
        } else {
          _containerFormDialog(
              _delDetContainerReturn.items.indexOf(e), e, dosContents);
        }
      } else {
        if (e["isChecked"] == 1 && !isSCan) {
          _scanningQty.text = "0";
        } else {
          _scanningQty.text = "1";
        }

        httpSaveScan(context, _delDetContainerReturn.items.indexOf(e));
      }
    });
  }

  Widget _detailsContTypeTable() {
    var count = 0;
    int ldcQty = 0;
    int ldbQty = 0;

    List rows = [];
    rows.addAll(_detailsContTypeReturn.items);
    rows.add({
      "barcode": "",
      "LDCQty": "",
      "LDBQty": "",
    });
    return DataTable(
      columns: [
        DataColumn(label: Text('Barcode')),
        DataColumn(label: Center(child: Text('Container'))),
        DataColumn(label: Center(child: Text('Box'))),
      ],
      rows: rows.map((e) {
        count++;
        if (count < rows.length) {
          ldcQty += e["ULCQty"];
          ldbQty += e["ULBQty"];
          return DataRow(
            cells: <DataCell>[
              DataCell(Text("${e["Barcode"]}")),
              DataCell(Center(child: Text("${e["ULCQty"]}"))),
              DataCell(Center(child: Text("${e["ULBQty"]}"))),
            ],
          );
        }
        return DataRow(
          cells: <DataCell>[
            DataCell(Text(
              "TOTAL",
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
            DataCell(Center(
                child: Text("$ldcQty",
                    style: TextStyle(fontWeight: FontWeight.bold)))),
            DataCell(Center(
                child: Text("$ldbQty",
                    style: TextStyle(fontWeight: FontWeight.bold)))),
          ],
        );
      }).toList(),
    );
  }

  Future<bool> _containerFormDialog(containerIndex, e, _dosContents) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Unloading Form"),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: ConstrainedBox(
                    constraints: new BoxConstraints(
                      minHeight: 300,
                      maxHeight: MediaQuery.of(context).size.height - 50,
                    ),
                    child: AbsorbPointer(
                      absorbing: false,
                      child: Form(
                        key: _issuingScanningFormkey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            TextFormField(
                              controller: _scanningBarcode,
                              keyboardType: TextInputType.text,
                              readOnly: true,
                              autofocus: false,
                              inputFormatters: <TextInputFormatter>[
                                LengthLimitingTextInputFormatter(20),
                              ],
                              onTap: () {},
                              decoration: InputDecoration(labelText: 'Barcode'),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Barcode is required!. ';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: _scanningQty,
                              keyboardType: TextInputType.number,
                              focusNode: focusNode,
                              autofocus: true,
                              readOnly: _isDisableQty,
                              inputFormatters: <TextInputFormatter>[
                                WhitelistingTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                              ],
                              decoration: InputDecoration(
                                  labelText: 'Unloading Quantity'),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Quantity is required!. ';
                                }
                                return null;
                              },
                            ),
                            Row(
                              children: <Widget>[
                                RadioButton(
                                  description: "Container",
                                  value: "1",
                                  groupValue: _scanningTypeID.text,
                                  onChanged: null,
                                  textPosition: RadioButtonTextPosition.right,
                                ),
                                RadioButton(
                                  description: "Box",
                                  value: "2",
                                  groupValue: _scanningTypeID.text,
                                  onChanged: null,
                                  textPosition: RadioButtonTextPosition.right,
                                ),
                              ],
                            ),
                            TextFormField(
                              controller: _scanningRemarks,
                              keyboardType: TextInputType.text,
                              autofocus: !_isReceived,
                              maxLines: 2,
                              readOnly: isComplete == 1,
                              inputFormatters: <TextInputFormatter>[
                                LengthLimitingTextInputFormatter(300),
                              ],
                              onTap: () {},
                              decoration: InputDecoration(labelText: 'Remarks'),
                            ),
                            _scanningBarcode.text.toUpperCase().contains("DOS")
                                ? Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 20, 0, 0),
                                    child: Column(
                                      children: [
                                        Align(
                                            alignment: Alignment.topLeft,
                                            child: Text("Content : ",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        Align(
                                            alignment: Alignment.topLeft,
                                            child: dosContents.length == 0
                                                ? Center(
                                                    child: Text(
                                                        "No Record found!"),
                                                  )
                                                : _dosContentTable(
                                                    _dosContents))
                                      ],
                                    ),
                                  )
                                : Text("")
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text('Close'),
              ),
              e == null
                  ? FlatButton(
                      onPressed: null,
                      child: Text('Save'),
                    )
                  : FlatButton(
                      onPressed: isComplete == 1 ||
                              (containerIndex != -1 && e['loadedQty'] == 0) ||
                              (e['offloadedQty'] == 0 && (e['isReceived'] == 1))
                          ? null
                          : () {
                              if (_issuingScanningFormkey.currentState
                                  .validate()) {
                                Navigator.of(context).pop(true);
                                httpSaveScan(issuingScaffoldKey.currentContext,
                                    containerIndex);
                              }
                            },
                      child: Text('Save'),
                    ),
            ],
          );
        });
  }

  Widget _dosContentTable(_dosContents) {
    return DataTable(
      columnSpacing: 10,
      columns: [
        DataColumn(label: Text('Qty')),
        DataColumn(label: Text('Description')),
      ],
      rows: _dosContents.map<DataRow>((e) {
        //if (count < rows.length) {
        return DataRow(
          cells: <DataCell>[
            DataCell(Text("${e["pluQty"]}")),
            DataCell(Text("${e["pluDesc"]}"))
          ],
        );
      }).toList(),
    );
  }

  Future getDOSContent(e) async {
    FormData formData = FormData.fromMap({
      "deliverDetailID": _scanningDeliverDetailID.text,
      "userEmpID": session.userEmployeeID,
    });

    var response = await Dio().post(
      apiDOSContent,
      data: formData,
      onSendProgress: (int sent, int total) {
        print("$sent $total");
      },
    );
    setState(() {
      dosContents = response.data['items'];
    });
    if (_scanningBarcode.text
        .contains(new RegExp('dos', caseSensitive: false))) {
      _containerFormDialog(
          _delDetContainerReturn.items.indexOf(e), e, dosContents);
    }
  }

  bool setTruckAndDriverVal(batch) {
    imageCache.clear();
    rawImage = ValueNotifier<ByteData>(null);
    setState(() {
      _selectedTruck.text = "";
      _selectedDriver.text = "";
      _isReceivedByBatch = false;
      _driverIndex = null;
      _truckIndex = null;
      _selectedBatchNo.text = batch;
    });
    if (_batchReturn != null && batch != "") {
      if (_batchReturn.items.length > 0) {
        for (int c = 0; c < _batchReturn.items.length; c++) {
          if (int.parse(batch) == _batchReturn.items[c]['batchNo']) {
            _isReceivedByBatch =
                _batchReturn.items[c]['isReceived'].toString() == ''
                    ? false
                    : _batchReturn.items[c]['isReceived'] == 1
                        ? true
                        : false;

            setState(() {
              _selectedTruck.text = _batchReturn.items[c]['truckID'].toString();
              int indx = 0;
              _driverList.forEach((element) {
                if (_batchReturn.items[c]['driverID'].toString() ==
                    element.id) {
                  _driverIndex = indx;
                  _selectedDriver.text =
                      _batchReturn.items[c]['driverID'].toString();
                }
                indx++;
              });

              int indx2 = 0;
              _truckList.forEach((element) {
                if (_batchReturn.items[c]['truckID'].toString() == element.id) {
                  _truckIndex = indx2;
                  _selectedTruck.text =
                      _batchReturn.items[c]['truckID'].toString();
                }
                indx2++;
              });

              httpGetWitness();
            });
          }
        }
      }
    }
  }

  Widget displayConfirmationTab() {
    print(
        '$apiSignatureFolder${_selectedDeliverID.text}/${_selectedLocationCode.text}/${_selectedDeliverID.text}-${_selectedBatchNo.text}.png');
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: Text(
              "Assigned Driver & Truck",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          _tdForm(),
          const Divider(),
          _isAllowedToShip == false
              ? Text("")
              : Container(
                  child: Column(
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Summary of Delivered Items",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        )),
                    _detailsContTypeReturn == null
                        ? Text("No Record")
                        : _detailsContTypeTable(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: <Widget>[
                              Text(
                                "Store Delivery Noted By",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          )),
                    ),
                    Visibility(
                        visible: true,
                        child: Column(
                          children: <Widget>[
                            Form(
                              key: _shippingFormKey,
                              child: TextFormField(
                                autofocus: false,
                                controller: notedBy,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Witness is required!. ';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.text,
                                readOnly: _isReceivedByBatch,
                                decoration:
                                    InputDecoration(labelText: 'Noted By'),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: 70,
                              color: Colors.white,
                              child: Center(
                                  child: InkWell(
                                onTap: _isReceivedByBatch == true
                                    ? null
                                    : () {
                                        _signFormDialog(context);
                                      },
                                child: Image.network(
                                  '$apiSignatureFolder${_selectedDeliverID.text}/${_selectedLocationCode.text}/${_selectedDeliverID.text}-${_selectedBatchNo.text}.png',
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildImageView();
                                  },
                                ),
                              )),
                            ),
                          ],
                        )),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          _isReceivedByBatch
                              ? Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.check,
                                        color: Colors.green,
                                        size: 26,
                                      ),
                                      Text("Already Received.",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.green))
                                    ],
                                  ),
                                )
                              : Flexible(
                                  child: SizedBox(
                                  width: double.infinity,
                                  child: RaisedButton(
                                    onPressed: isComplete == 1
                                        ? null
                                        : () async {
                                            try {
                                              if (_shippingFormKey.currentState
                                                  .validate()) {
                                                if (_withWitness) {
                                                  print(rawImage.value.buffer
                                                      .asUint8List()
                                                      .toString());
                                                }
                                                httpUpdateWitness();
                                              }
                                            } catch (e) {
                                              Flushbar(
                                                title: "Failed!",
                                                message:
                                                    "MESSAGE : Noted By signature is required!",
                                                icon: Icon(
                                                  Icons.warning,
                                                  size: 28,
                                                  color: Colors.white,
                                                ),
                                                backgroundColor: Colors.orange,
                                                duration: Duration(seconds: 5),
                                              ).show(context);
                                            }
                                          },
                                    color: Colors.green,
                                    child: Text('Click here to Received',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                )),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 120,
                    )
                  ],
                )),
        ],
      ),
    );
  }

  Widget _tdForm() {
    return Form(
      key: _confirmationFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _truckList.length == 0
              ? Text("")
              : DropdownSearch<DropDown>(
                  items: _truckList,
                  itemAsString: (DropDown u) => u.name,
                  selectedItem:
                      _truckIndex == null ? null : _truckList[_truckIndex],
                  enabled: false,
                  maxHeight: 300,
                  label: "Truck.",
                  onChanged: (e) {
                    setState(() {
                      print(e.name);
                      int c = 0;
                      _truckList.forEach((element) {
                        if (e.id == element.id) {
                          _truckIndex = c;
                        }
                        c++;
                      });
                      _selectedTruck.text = e.id;
                    });
                  },
                  showSearchBox: true,
                ),
          SizedBox(
            height: 20,
          ),
          _driverList.length == 0
              ? Text("")
              : DropdownSearch<DropDown>(
                  items: _driverList,
                  itemAsString: (DropDown u) => u.name,
                  selectedItem:
                      _driverIndex == null ? null : _driverList[_driverIndex],
                  maxHeight: 300,
                  enabled: false,
                  label: "Driver.",
                  onChanged: (e) {
                    setState(() {
                      print(e.name);
                      int c = 0;
                      _driverList.forEach((element) {
                        if (e.id == element.id) {
                          _driverIndex = c;
                        }
                        c++;
                      });
                      _selectedDriver.text = e.id;
                    });
                  },
                  showSearchBox: true,
                ),
        ],
      ),
    );
  }

  Widget _buildImageView() {
    return Container(
      width: MediaQuery.of(context).size.width - 20,
      height: 96.0,
      decoration: BoxDecoration(
        border: Border.all(),
        color: Colors.white30,
      ),
      child: ValueListenableBuilder<ByteData>(
        valueListenable: rawImage,
        builder: (context, data, child) {
          if (data == null) {
            return Container(
              color: Colors.white,
              child: Center(
                  child: InkWell(
                onTap: _isReceivedByBatch == true
                    ? null
                    : () {
                        _signFormDialog(context);
                        print("received!");
                      },
                child: Text('For witness signature, click here!.'),
              )),
            );
          } else {
            return InkWell(
              onTap: () {
                _signFormDialog(context);
              },
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Image.memory(data.buffer.asUint8List()),
              ),
            );
          }
        },
      ),
    );
  }

  Future _scan(context) async {
    setState(() {
      isSCan = true;
    });
    this._scanningBarcode.text = '';
    this._scanningQty.text = '';
    this._scanningRemarks.text = '';
    this._scanningTypeID.text = '';
    this._scanningZone.text = '';

    try {
      String barcode = await BarcodeScanner.scan();
      if (barcode != null) {
        setState(() {
          this._scanningBarcode.text = barcode;
          _responseEffect(1);
          if (this._scanningBarcode.text != '') {
            var e;
            for (int c = 0; c < _delDetContainerReturn.items.length; c++) {
              String barcode = '';
              if (_delDetContainerReturn.items[c]["detailType_ID"] == 2) {
                barcode = "${_delDetContainerReturn.items[c]["container"]}";
              } else {
                barcode =
                    "${_delDetContainerReturn.items[c]["container"]}-${_selectedLocationCode.text}";
              }

              if (this
                  ._scanningBarcode
                  .text
                  .contains(new RegExp('-$barcode', caseSensitive: false))) {
                this._scanningBarcode.text = barcode;
                e = _delDetContainerReturn.items[c];
                check(e);
                return true;
              }
            }
            if (_scanningBarcode.text
                .contains(new RegExp('dos', caseSensitive: false))) {
              getDOSContent(e);
            } else {
              _containerFormDialog(-1, e, dosContents);
            }
            return false;
          }
        });
      }
    } on PlatformException catch (e) {
      print("Scanner Errror: $e");
    }
  }

  void _responseEffect(int type) async {
    if (type == 0) {
      errorScanPlayer.play();
    } else {
      scanPlayer.play();
    }
    await Vibration.vibrate();
  }

  _signFormDialog(contx) {
    showGeneralDialog(
        context: contx,
        barrierDismissible: true,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black45,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext context, Animation animation,
            Animation secondaryAnimation) {
          return Center(
            child: Container(
              width: MediaQuery.of(contx).size.width - 10,
              height: MediaQuery.of(contx).size.height / 1.7,
              padding: EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text("Witness Signature",
                        style: TextStyle(
                          fontSize: 14,
                        )),
                  ),
                  Center(
                    child: AspectRatio(
                      aspectRatio: 1.6,
                      child: Stack(
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.black,
                                border: Border.all(
                                  color: Theme.of(contx).accentColor,
                                )),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Container(
                                constraints: BoxConstraints.expand(),
                                color: Colors.white,
                                child: HandSignaturePainterView(
                                  control: control,
                                  type: SignatureDrawType.shape,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          RaisedButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: Text(
                              "Close",
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Colors.orangeAccent,
                          ),
                          SizedBox(width: 2),
                          RaisedButton(
                            onPressed: () {
                              control.clear();
                            },
                            child: Text(
                              "Clear",
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Colors.orange,
                          ),
                          SizedBox(width: 2),
                          RaisedButton(
                            onPressed: () async {
                              rawImage.value = await control.toImage(
                                color: Colors.blueAccent,
                              );
                              setState(() {
                                signatureResult = rawImage;
                              });
                              Navigator.of(context).pop(false);
                            },
                            child: Text(
                              "Save",
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  searchFN(String keyword, items) {
    List<int> ret = List<int>();
    if (keyword != null && items != null && keyword.isNotEmpty) {
      keyword.split(" ").forEach((k) {
        int i = 0;
        items.forEach((item) {
          if (k.isNotEmpty &&
              (item.child.data
                  .toString()
                  .toLowerCase()
                  .contains(k.toLowerCase()))) {
            ret.add(i);
          }
          i++;
        });
      });
    }
    if (keyword.isEmpty) {
      ret = Iterable<int>.generate(items.length).toList();
    }
    return (ret);
  }

  Future httpUploadSignature() async {
    FormData formData = FormData.fromMap({
      "deliverID": _selectedDeliverID.text,
      "batch": _selectedBatchNo.text,
      "locCode": _selectedLocationCode.text,
      "signature": MultipartFile.fromBytes(rawImage.value.buffer.asUint8List(),
          filename: "${_selectedDeliverID.text}-${_selectedBatchNo.text}.png")
    });

    var response = await Dio().post(
      apiUploadUrl,
      data: formData,
      onSendProgress: (int sent, int total) {
        print("$sent $total");
      },
    );
    print(response.statusCode);
    print("Upload response >>>>> ${response.toString()}");
  }

  Future<bool> _logout(_context) {
    print("BACK>>>>>>>>>");
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('You want to logout?'),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          FlatButton(
            onPressed: () {
              session.destroySession();
              Navigator.of(context).pop();
              Navigator.of(context).push(new PageRouteBuilder(
                  pageBuilder: (BuildContext context, _, __) {
                return new LoginView();
              }, transitionsBuilder:
                      (_, Animation<double> animation, __, Widget child) {
                return new FadeTransition(opacity: animation, child: child);
              }));
            },
            /*Navigator.of(context).pop(true)*/
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _searchDialog(context2) {
    showDialog(
      context: context2,
      builder: (BuildContext context) {
        // return object of type Dialog
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: new Text("Search Delivery"),
            content: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: _issuingSearchFormKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            controller: _searchControlNo,
                            keyboardType: TextInputType.text,
                            readOnly: false,
                            inputFormatters: <TextInputFormatter>[
                              LengthLimitingTextInputFormatter(20),
                            ],
                            onTap: () {},
                            decoration:
                                InputDecoration(labelText: 'Control No'),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Text("Unloaded?",
                                    style: new TextStyle(fontSize: 12))),
                          ),
                          Row(
                            children: <Widget>[
                              RadioButton(
                                description: "Yes",
                                value: "1",
                                groupValue: _searchIsLoaded.text,
                                onChanged: (value) => setState(
                                  () => _searchIsLoaded.text = value,
                                ),
                                textPosition: RadioButtonTextPosition.right,
                              ),
                              RadioButton(
                                description: "No",
                                value: "0",
                                groupValue: _searchIsLoaded.text,
                                onChanged: (value) => setState(
                                  () => _searchIsLoaded.text = value,
                                ),
                                textPosition: RadioButtonTextPosition.right,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text(
                  "SEARCH",
                  style: new TextStyle(color: Colors.orangeAccent),
                ),
                onPressed: () {
                  httpGetIssuingDelivery();
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text("CLOSE",
                    style: new TextStyle(color: Colors.orangeAccent)),
                onPressed: () {
                  if (_issuingSearchFormKey.currentState.validate()) {
                    Navigator.of(context).pop();
                  }
                  // _scan(context2);
                },
              ),
            ],
          );
        });
      },
    );
  }

  Future httpGetIssuingDelivery() async {
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      return null;
    }

    print("empID: ${session.userEmployeeID.toString()}," +
        "isUnloaded: ${_searchIsLoaded.text == "" ? "0" : _searchIsLoaded.text}," +
        "controlNo: ${_searchControlNo.text}," +
        "locID: ${session.userLocationID.toString()}");

    IssuingDeliverySubmit res = new IssuingDeliverySubmit(
        empID: session.userEmployeeID.toString(),
        isUnloaded: _searchIsLoaded.text == "" ? "0" : _searchIsLoaded.text,
        controlNo: _searchControlNo.text,
        locID: session.userLocationID.toString());

    IssuingDeliveryReturn res2 =
        await IssuingDeliveryController.getIssuingDelivery(res);

    setState(() {
      _issuingDeliveryReturn = res2;
    });
  }

  Future httpGetIssuingDeliveryByDONo() async {
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      return null;
    }
    IssuingDeliverySubmit res = new IssuingDeliverySubmit(
        empID: session.userEmployeeID.toString(),
        isUnloaded: _searchIsLoaded.text == "" ? "0" : _searchIsLoaded.text,
        controlNo: _selectedDONo.text,
        locID: session.userLocationID.toString());

    IssuingDeliveryReturn res2 =
        await IssuingDeliveryController.getIssuingDelivery(res);

    setState(() {
      if (res2 != null) {
        if (res2.items.length > 0) {
          totalContainer = res2.items[0]['totalContainer'];
          totalScannedQty = res2.items[0]['totalScannedQty'];
          totalLoadedQty = res2.items[0]['totalLoadedQty'];
          totalUnloadedQty = res2.items[0]['totalUnloadedQty'];
          totalOffLoadedQty = res2.items[0]['totalOffLoadedQty'];
          isComplete = res2.items[0]['isComplete'];
        }
      }
    });
  }

  Future httpGetBatch() async {
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();

    if (!validateConnection) {
      return null;
    }

    BatchSubmit res = new BatchSubmit(
        deliverID: _selectedDeliverID.text,
        empID: session.userEmployeeID.toString());

    BatchReturn res2 = await BatchController.getBatch(res);

    setState(() {
      _batchReturn = res2;
      print(_batchList2.length);
      _batchList.clear();
      int count = 0;
      for (int c = 0; c < _batchReturn.items.length; c++) {
        _batchList.add(DropDown(
            id: "${_batchReturn.items[c]['batchNo']}",
            name: "Batch #${_batchReturn.items[c]['batchNo']}"));
        count++;
      }
      if (count > 0) {
        _selectedBatchNo.text = count.toString();
        _batchIndex = count - 1;
      }
      print("SELECTED BATCH >>> ${_selectedBatchNo.text}");
      setTruckAndDriverVal(_selectedBatchNo.text);
      httpGetDetailsContType();
      httpGetWitness();
    });
  }

  Future httpUpdateDelivery() async {
    pr = new Loading(context);
    pr.load().show();
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      pr.load().hide();
      return null;
    }

    DeliveryUpdateSubmit res = new DeliveryUpdateSubmit(
        deliverID: _selectedDeliverID.text,
        receivedBy: session.userEmployeeID.toString(),
        isReceived: totalOffLoadedQty == 0 ? "1" : "0");

    DeliveryUpdateReturn res2 =
        await DeliveryUpdateController.getDeliveryUpdate(res);

    _isReceivedByBatch = false;
    setState(() {
      _deliveryUpdateReturn = res2;
      if (_deliveryUpdateReturn != null) {
        if (_deliveryUpdateReturn.apiReturn >= 0) {
          _isReceivedByBatch = true;
          httpUpdateDelShip();
        } else {
          Flushbar(
            title: "Failed!",
            message: res2.apiMsg,
            icon: Icon(
              Icons.warning,
              size: 28,
              color: Colors.white,
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 1),
          ).show(context);
        }
      }
    });
    pr.load().hide();
  }

  Future httpUpdateDelShip() async {
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      pr.load().hide();
      return null;
    }

    print("deliverID: ${_selectedDeliverID.text}" +
        "batchNo: ${_selectedBatchNo.toString()} " +
        "empID: ${session.userEmployeeID.toString()}");

    UpdateDelShipSubmit res = new UpdateDelShipSubmit(
        deliverID: _selectedDeliverID.text,
        batchNo: _selectedBatchNo.text.toString(),
        empID: session.userEmployeeID.toString());

    UpdateDelShipReturn res2 =
        await UpdateDelShipController.getUpdateDelShip(res);
    if (res2 != null) {
      if (res2.apiReturn >= 0) {
        Flushbar(
          title: "Successfully!",
          message: res2.apiMsg,
          icon: Icon(
            Icons.warning,
            size: 28,
            color: Colors.white,
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ).show(context);
      } else {
        Flushbar(
          title: "Failed!",
          message:
              "MESSAGE : ${res2.apiMsg} \n ERROR CODE : [${res2.apiReturn}]",
          icon: Icon(
            Icons.warning,
            size: 28,
            color: Colors.white,
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 5),
        ).show(context);
      }
    }
  }

  Future httpGetTruck() async {
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      return null;
    }
    TruckSubmit res = new TruckSubmit(truckID: "0", truckNo: "");
    TruckReturn res2 = await TruckController.getTruck(res);
    setState(() {
      _truckReturn = res2;
      _truckList.clear();
      for (int c = 0; c < _truckReturn.items.length; c++) {
        _truckList.add(DropDown(
            id: _truckReturn.items[c]['truckID'].toString(),
            name: "${_truckReturn.items[c]['truckNo']}"));
      }
    });
  }

  Future httpSaveAssignedTD() async {
    pr = new Loading(context);
    pr.load().show();
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      pr.load().hide();
      return null;
    }

    ShippingSubmit res = new ShippingSubmit(
        deliverID: _selectedDeliverID.text,
        truckID: _selectedTruck.text,
        driverID: _selectedDriver.text,
        empID: session.userEmployeeID.toString());
    ShippingReturn res2 = await ShippingController.getShipping(res);
    setState(() {
      _shippingReturn = res2;
      if (_shippingReturn != null) {
        if (_shippingReturn.apiReturn >= 0) {
          httpGetDetailsContType();
          Flushbar(
            title: "Successfully!",
            message: res2.apiMsg,
            icon: Icon(
              Icons.warning,
              size: 28,
              color: Colors.white,
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ).show(context);
        } else {
          Flushbar(
            title: "Failed!",
            message: res2.apiMsg,
            icon: Icon(
              Icons.warning,
              size: 28,
              color: Colors.white,
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 1),
          ).show(context);
        }
      }
    });
    pr.load().hide();
  }

  Future httpGetDriver() async {
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      return null;
    }
    DriverSubmit res = new DriverSubmit(driverID: "0", driverName: "");
    DriverReturn res2 = await DriverController.getDriver(res);
    setState(() {
      _driverReturn = res2;
      _driverList.clear();
      for (int c = 0; c < _driverReturn.items.length; c++) {
        _driverList.add(DropDown(
            id: _driverReturn.items[c]['Driver_ID'].toString(),
            name: "${_driverReturn.items[c]['DriverName']}"));
      }
    });
  }

  Future httpGetDetailsContType() async {
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      return null;
    }

    DetailsContTypeSubmit res = new DetailsContTypeSubmit(
        deliverID: _selectedDeliverID.text,
        empID: session.userEmployeeID.toString(),
        batchNo: _selectedBatchNo.text);

    DetailsContTypeReturn res2 =
        await DetailsContTypeController.getDetailsContType(res);
    setState(() {
      _detailsContTypeReturn = res2;
      print("Details Cont >> ${_detailsContTypeReturn.items}");
      if (_detailsContTypeReturn != null) {
        if (_detailsContTypeReturn.items.length > 0) {
          _isAllowedToShip = true;
        } else {
          _isAllowedToShip = false;
        }
      }
    });
  }

  Future httpSaveScan(context, recordIndex) async {
    print("Index >>>>>>>> $recordIndex");
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      return null;
    }

    print("deliverID >> ${_selectedDeliverID.text}");
    print("ddID >> ${_scanningDeliverDetailID.text}");
    print("barcode >> ${_scanningBarcode.text}");
    print("typeID >> ${_scanningTypeID.text}");
    print("qty >> ${_scanningQty.text}");
    print("status >> ${_scanningStatus.text}");
    print("empID >> ${session.userEmployeeID.toString()}");
    print("remarks >> ${_scanningRemarks.text}");

    DelDetUpdateStatusSubmit res = new DelDetUpdateStatusSubmit(
        deliverID: _selectedDeliverID.text,
        ddID: _scanningDeliverDetailID.text,
        barcode: _scanningBarcode.text,
        qty: _scanningQty.text,
        status: "2",
        empID: session.userEmployeeID.toString(),
        remarks: _scanningRemarks.text);
    DelDetUpdateStatusReturn res2 =
        await DelDetUpdateStatusController.getDelDetUpdateStatus(res);
    delDetUpdateStatusReturn = res2;
    if (res2 != null) {
      if (res2.apiReturn >= 0) {
        httpGetDeliveryCount();
        httpGetDelDetContainer();
        return true;
      } else {
        Flushbar(
          title: "Failed!",
          message: "${res2.apiMsg}\n Error code:  ${res2.apiReturn}",
          icon: Icon(
            Icons.warning,
            size: 28,
            color: Colors.white,
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 1),
        ).show(context);
        return false;
      }
    }
  }

  Future httpGetDeliveryCount() async {
    DateTime testStart = DateTime.now();
    DateTime testEnd;
    print("**************GET DELIVERY DETAILS*************");
    print("Start: $testStart");
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      return null;
    }
    DeliveryCountSubmit res =
        new DeliveryCountSubmit(deliverID: _selectedDeliverID.text);
    DeliveryCountReturn res2 =
        await DeliveryCountController.getDeliveryCount(res);

    print("${res2.items}");
    setState(() {
      if (res2 != null) {
        if (res2.items.length > 0) {
          totalContainer = res2.items[0]['totalContainer'];
          totalScannedQty = res2.items[0]['totalScannedQty'];
          totalLoadedQty = res2.items[0]['totalLoadedQty'];
          totalUnloadedQty = res2.items[0]['totalUnloadedQty'];
          totalOffLoadedQty = res2.items[0]['totalOffloadedQty'];
          isComplete = res2.items[0]['isComplete'];
          testEnd = DateTime.now();
        }
      }
    });
  }

  Future httpGetDelDetContainer() async {
    pr = new Loading(context);
    pr.load().show();
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      pr.load().hide();
      return null;
    }
    print("deliverID: ${_selectedDeliverID.text}");
    DelDetContainerSubmit res = new DelDetContainerSubmit(
        deliverID: _selectedDeliverID.text,
        status: '2',
        empID: session.userEmployeeID.toString());
    DelDetContainerReturn res2 =
        await DelDetContainerController.getDelDetContainer(res);
    setState(() {
      _delDetContainerReturn = res2;
      if (_delDetContainerReturn != null) {
        print(
            "*********** HTTP GET >>CONTAINER DETAILS<< RESULT *************");
        print("Items: \n${_delDetContainerReturn.items}");
      }
    });
    pr.load().hide();
  }

  Future httpUpdateWitness() async {
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      return null;
    }

    WitnessUpdateSubmit res = new WitnessUpdateSubmit(
        deliverID: _selectedDeliverID.text,
        empID: session.userEmployeeID.toString(),
        witness: notedBy.text,
        batchNo: _selectedBatchNo.text);
    WitnessUpdateReturn res2 =
        await WitnessUpdateController.getWitnessUpdate(res);
    setState(() {
      _witnessUpdateReturn = res2;
      if (_witnessUpdateReturn != null) {
        if (_witnessUpdateReturn.apiReturn > 0) {
          print("witness update ${_witnessUpdateReturn.apiReturn}");
          httpUploadSignature();
          httpUpdateDelivery();
        } else {
          Flushbar(
            title: "Failed!",
            message:
                "MESSAGE : ${res2.apiMsg} \n ERROR CODE : [${res2.apiReturn}]",
            icon: Icon(
              Icons.warning,
              size: 28,
              color: Colors.white,
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ).show(context);
        }
      }
    });
  }

  Future httpGetWitness() async {
    print("WITNESS >>>>");
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      return null;
    }

    WitnessSubmit res = new WitnessSubmit(
        deliverID: _selectedDeliverID.text,
        empID: session.userEmployeeID.toString(),
        batchNo: _selectedBatchNo.text);
    WitnessReturn res2 = await WitnessController.getWitness(res);
    setState(() {
      _witnessReturn = res2;
      if (_witnessReturn != null) {
        if (_witnessReturn.items.length > 0) {
          print(_witnessReturn.items);
          notedBy.text = _witnessReturn.items[0]['WitnessRec'];
        }
      }
    });
  }
}
