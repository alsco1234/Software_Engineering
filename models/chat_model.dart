class ChatModel {
  final String role;
  final String msg;
  final int chatIndex;

  /// 기존 chatModel에 role을 구별하는 인자 추가함
  ChatModel({required this.role, required this.msg, required this.chatIndex});

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
        role: json["role"],
        msg: json["msg"],
        chatIndex: json["chatIndex"],
      );
}
