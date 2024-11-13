import 'package:cloud_firestore/cloud_firestore.dart';

class GroupChatMessageModel {
  List<Id>? id;
  String? content;
  String? timestamp;
  String? groupname;
  String? idFrom;
  String? senderName;

  GroupChatMessageModel({
    this.id,
    this.content,
    this.timestamp,
    this.groupname,
    this.idFrom,
    this.senderName,
  });

  GroupChatMessageModel.fromJson(Map<String, dynamic> json) {
    if (json['id'] != null) {
      id = <Id>[];
      json['id'].forEach((v) {
        id!.add(Id.fromJson(v));
      });
    }
    content = json['content'];
    timestamp = json['timestamp'];
    groupname = json['groupname'];
    idFrom = json['idFrom'];
    senderName = json['senderName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != null) {
      data['id'] = id!.map((v) => v.toJson()).toList();
    }
    data['content'] = content;
    data['timestamp'] = timestamp;
    data['groupname'] = groupname;
    data['idFrom'] = idFrom;
    data['senderName'] = senderName;
    return data;
  }

  factory GroupChatMessageModel.fromDocument(
      DocumentSnapshot documentSnapshot) {
    // List<Id> id = documentSnapshot.get('id');
    String timestamp = documentSnapshot.get('timestamp');
    String content = documentSnapshot.get('content');
    String groupname = documentSnapshot.get('groupname');
    String idFrom = documentSnapshot.get('idFrom');
    String senderName = documentSnapshot.get('senderName');

    return GroupChatMessageModel(
        timestamp: timestamp,
        content: content,
        groupname: groupname,
        idFrom: idFrom,
        senderName: senderName);
  }
}

class Id {
  String? peerId;
  String? peerName;
  String? peerFcmToken;

  Id({this.peerId, this.peerName, this.peerFcmToken});

  Id.fromJson(Map<String, dynamic> json) {
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

// class GroupChatMessageModel {
//   List<String>? id;
//   String? content;
//   String? timestamp;
//   String? groupname;
//   String? idFrom;

//   GroupChatMessageModel(
//       {this.id, this.content, this.timestamp, this.groupname, this.idFrom});

//   GroupChatMessageModel.fromJson(Map<String, dynamic> json) {
//     id = json['id'].cast<String>();
//     content = json['content'];
//     timestamp = json['timestamp'];
//     groupname = json['groupname'];
//     idFrom = json['idFrom'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id;
//     data['content'] = content;
//     data['timestamp'] = timestamp;
//     data['groupname'] = groupname;
//     data['idFrom'] = idFrom;
//     return data;
//   }

//   factory GroupChatMessageModel.fromDocument(
//       DocumentSnapshot documentSnapshot) {
//     // List<String> id = documentSnapshot.get('id');
//     String timestamp = documentSnapshot.get('timestamp');
//     String content = documentSnapshot.get('content');
//     String groupname = documentSnapshot.get('groupname');
//     String idFrom = documentSnapshot.get('idFrom');

//     return GroupChatMessageModel(
//         timestamp: timestamp,
//         content: content,
//         groupname: groupname,
//         idFrom: idFrom);
//   }
// }
