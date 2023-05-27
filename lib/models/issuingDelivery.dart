class IssuingDeliverySubmit {
  final String empID;
  final String isUnloaded;
  final String controlNo;
  final String locID;

  IssuingDeliverySubmit({this.empID, this.isUnloaded, this.controlNo, this.locID});

  factory IssuingDeliverySubmit.fromJson(Map<String, dynamic> json) {
    return IssuingDeliverySubmit(
        empID: json['empID'],
        isUnloaded: json['isUnloaded'],
        controlNo: json['controlNo'],
        locID: json['locID']);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["empID"] = empID;
    map["isUnloaded"] = isUnloaded;
    map["controlNo"] = controlNo;
    map["locID"] = locID;
    return map;
  }
}

class IssuingDeliveryReturn {
  final int apiReturn;
  final String apiMsg;
  final List<dynamic> items;

  IssuingDeliveryReturn({this.apiReturn, this.apiMsg, this.items});

  factory IssuingDeliveryReturn.fromJson(Map<String, dynamic> parsedJson) {
    return IssuingDeliveryReturn(
      apiReturn: parsedJson['apiReturn'],
      apiMsg: parsedJson['apiMsg'],
      items: parsedJson['items'],
    );
  }
}
