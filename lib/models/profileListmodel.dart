class ProfileList {
  String? message;
  String? frontendMessage;
  List<Data>? data;

  ProfileList({this.message, this.frontendMessage, this.data});

  ProfileList.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    frontendMessage = json['frontendMessage'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['frontendMessage'] = frontendMessage;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? jobId;
  String? jobName;
  String? imageName;

  Data({this.jobId, this.jobName, this.imageName});

  Data.fromJson(Map<String, dynamic> json) {
    jobId = json['jobId'];
    jobName = json['jobName'];
    imageName = json['imageName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['jobId'] = jobId;
    data['jobName'] = jobName;
    data['imageName'] = imageName;
    return data;
  }
}
