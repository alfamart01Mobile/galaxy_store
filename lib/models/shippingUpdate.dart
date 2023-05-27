class ShippingUpdateSubmit {
  final String deliverID;
  final String bacth;
  final String truckID;
  final String driverID;
  final String empID;

  ShippingUpdateSubmit({this.deliverID,this.bacth, this.truckID, this.driverID, this.empID});

  factory ShippingUpdateSubmit.fromJson(Map<String, dynamic> json) {
    return ShippingUpdateSubmit(
        deliverID: json['deliverID'],
        bacth: json['bacth'],
        truckID: json['truckID'],
        driverID: json['driverID'],
        empID: json['empID']);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["deliverID"] = deliverID;
      map["bacth"] = bacth;
    map["truckID"] = truckID;
    map["deliverID"] = deliverID;
    map["empID"] = empID;
    return map;
  }
}

class ShippingUpdateReturn {
  final int apiReturn;
  final String apiMsg;
  final List<dynamic> items;

  ShippingUpdateReturn({this.apiReturn, this.apiMsg, this.items});

  factory ShippingUpdateReturn.fromJson(Map<String, dynamic> parsedJson) {
    return ShippingUpdateReturn(
      apiReturn: parsedJson['apiReturn'],
      apiMsg: parsedJson['apiMsg'],
      items: parsedJson['items'],
    );
  }
}
