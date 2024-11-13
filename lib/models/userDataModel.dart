class UserDataModel {
  String? id;
  String? name;
  String? phoneNumber;
  List<GroupIds>? groupIds;
  String? fcmToken;
  String? email;

  UserDataModel(
      {this.id,
      this.name,
      this.phoneNumber,
      this.groupIds,
      this.fcmToken,
      this.email});

  UserDataModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phoneNumber = json['phoneNumber'];
    fcmToken = json['fcmToken'];
    email = json['email'];
    if (json['groupIds'] != null) {
      groupIds = <GroupIds>[];
      json['groupIds'].forEach((v) {
        groupIds!.add(GroupIds.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phoneNumber'] = phoneNumber;
    data['fcmToken'] = fcmToken;
    data['email'] = email;
    if (groupIds != null) {
      data['groupIds'] = groupIds!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class GroupIds {
  String? peerId;
  String? peerName;
  String? peerFcmToken;

  GroupIds({this.peerId, this.peerName, this.peerFcmToken});

  GroupIds.fromJson(Map<String, dynamic> json) {
    peerId = json['peerId'];
    peerName = json['peerName'];
    peerFcmToken = json['peerFcmToken'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['peerId'] = peerId;
    data['peerName'] = peerName;
    data['peerFcmToken'] = peerFcmToken;
    return data;
  }
}
