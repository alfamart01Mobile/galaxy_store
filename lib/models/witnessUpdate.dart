class WitnessUpdateSubmit {
  final String deliverID;
  final String batchNo;  
  final String witness;
  final String empID;

  WitnessUpdateSubmit({this.deliverID,this.batchNo,this.witness, this.empID});

  factory WitnessUpdateSubmit.fromJson(Map<String, dynamic> json) {
    return WitnessUpdateSubmit(
        deliverID: json['deliverID'],
        batchNo: json['batchNo'],  
        witness: json['witness'], 
        empID: json['empID']);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["deliverID"] = deliverID;
    map["batchNo"] = batchNo;  
    map["witness"] = witness;  
    map["empID"] = empID;
    return map;
  }
}

class WitnessUpdateReturn {
  final int apiReturn;
  final String apiMsg;
  final List<dynamic> items;

  WitnessUpdateReturn({this.apiReturn, this.apiMsg, this.items});

  factory WitnessUpdateReturn.fromJson(Map<String, dynamic> parsedJson) {
    return WitnessUpdateReturn(
      apiReturn: parsedJson['apiReturn'],
      apiMsg: parsedJson['apiMsg'],
      items: parsedJson['items'],
    );
  }
}
