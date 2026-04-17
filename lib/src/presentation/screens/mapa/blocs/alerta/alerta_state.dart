class AlertState {
  final bool isSending;
  final bool success;
  final String? error;

  AlertState({this.isSending = false, this.success = false, this.error});

  AlertState copyWith({bool? isSending, bool? success, String? error}) {
    return AlertState(
      isSending: isSending ?? this.isSending,
      success: success ?? this.success,
      error: error,
    );
  }
}
