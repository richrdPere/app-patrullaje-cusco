class BaseResponse {
  final bool success;
  final String message;

  BaseResponse({required this.success, required this.message});

  factory BaseResponse.fromJson(Map<String, dynamic> json) {
    return BaseResponse(success: json["success"], message: json["message"]);
  }
}
