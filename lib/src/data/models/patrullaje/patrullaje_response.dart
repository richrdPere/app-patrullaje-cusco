import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_data.dart';

// PatrullajeResponse patrullajeResponseFromJson(String str) =>
//     PatrullajeResponse.fromJson(json.decode(str));

// String patrullajeResponseToJson(PatrullajeResponse data) =>
//     json.encode(data.toJson());

class PatrullajeResponse {
  bool success;
  String message;
  PatrullajeData data;

  PatrullajeResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PatrullajeResponse.fromJson(Map<String, dynamic> json) =>
      PatrullajeResponse(
        success: json["success"],
        message: json["message"],
        data: PatrullajeData.fromJson(json["data"]),
      );

  // Map<String, dynamic> toJson() => {
  //   "success": success,
  //   "message": message,
  //   "data": data.toJson(),
  // };

  PatrullajeResponse copyWith({
    bool? success,
    String? message,
    PatrullajeData? data,
  }) => PatrullajeResponse(
    success: success ?? this.success,
    message: message ?? this.message,
    data: data ?? this.data,
  );
}
