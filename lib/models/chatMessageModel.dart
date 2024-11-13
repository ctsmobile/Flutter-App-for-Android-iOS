import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessagesModel {
  String? id;
  String? name;
  String? idFrom;
  String? idTo;
  String? timestamp;
  String? content;
  String? uniqueId;
  int? type;
  String? peerFcmToken;

  ChatMessagesModel(
      {this.id,
      this.name,
      this.idFrom,
      this.idTo,
      this.timestamp,
      this.content,
      this.uniqueId,
      this.type,
      this.peerFcmToken});

  ChatMessagesModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    idFrom = json['idFrom'];
    idTo = json['idTo'];
    timestamp = json['timestamp'];
    content = json['content'];
    uniqueId = json['uniqueId'];
    type = json['type'];
    peerFcmToken = json['peerFcmToken'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['idFrom'] = idFrom;
    data['idTo'] = idTo;
    data['timestamp'] = timestamp;
    data['content'] = content;
    data['uniqueId'] = uniqueId;
    data['type'] = type;
    data['peerFcmToken'] = peerFcmToken;
    return data;
  }

  factory ChatMessagesModel.fromDocument(DocumentSnapshot documentSnapshot) {
    String id = documentSnapshot.get('id');
    String name = documentSnapshot.get('name');
    String idFrom = documentSnapshot.get('idFrom');
    String idTo = documentSnapshot.get('idTo');
    String timestamp = documentSnapshot.get('timestamp');
    String content = documentSnapshot.get('content');
    String uniqueId = documentSnapshot.get('uniqueId');
    String peerFcmToken = documentSnapshot.get('peerFcmToken');
    int type = documentSnapshot.get('type');

    return ChatMessagesModel(
        id: id,
        name: name,
        idFrom: idFrom,
        idTo: idTo,
        timestamp: timestamp,
        content: content,
        uniqueId: uniqueId,
        type: type,
        peerFcmToken: peerFcmToken);
  }
}
