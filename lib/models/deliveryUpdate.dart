class DeliveryUpdateSubmit {
  final String deliverID;
  final String receivedBy;
  final String isReceived; 

  DeliveryUpdateSubmit(
      {this.deliverID,
      this.receivedBy,
      this.isReceived});

  factory DeliveryUpdateSubmit.fromJson(Map<String, dynamic> json) {
    return DeliveryUpdateSubmit(
        deliverID: json['deliverID'],
        receivedBy: json['receivedBy'],
        isReceived: json['isReceived']);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["deliverID"] = deliverID;
    map["receivedBy"] = receivedBy;
    map["isReceived"] = isReceived; 
    return map;
  }
}

class DeliveryUpdateReturn {
  final int apiReturn;
  final String apiMsg;
  final List<dynamic> items;

  DeliveryUpdateReturn({this.apiReturn, this.apiMsg, this.items});

  factory DeliveryUpdateReturn.fromJson(Map<String, dynamic> parsedJson) {
    return DeliveryUpdateReturn(
      apiReturn: parsedJson['apiReturn'],
      apiMsg: parsedJson['apiMsg'],
      items: parsedJson['items'],
    );
  }
}
