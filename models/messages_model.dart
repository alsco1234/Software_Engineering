class MessagesModel {
  final String role;
  final String msg;

  /// gpt model에게 request를 보낼 때, 이전 대화 기록을 함께 보낼 용도로 만든 class
  /// 인자를 제공하면 그에 맞는 request body의 messages format에 맞는 json으로 변환함
  /// 참고: https://platform.openai.com/docs/guides/chat
  MessagesModel(this.role, this.msg);

  Map<String, dynamic> toJson() =>{
    'role': role, 'content': msg
  };
}
