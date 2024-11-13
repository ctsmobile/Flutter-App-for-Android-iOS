class ContactListModel {
  String? id;
  String? name;
  String? fcmToken;
  bool? isSelected;

  ContactListModel({this.id, this.name, this.isSelected});

  ContactListModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    fcmToken = json['fcmToken'];
    isSelected = json['isSelected'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['fcmToken'] = fcmToken;
    data['isSelected'] = isSelected;
    return data;
  }
}
