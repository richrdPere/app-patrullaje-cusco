abstract class AlertEvent {}

class SendAlertEvent extends AlertEvent {
  final double lat;
  final double lng;

  SendAlertEvent({required this.lat, required this.lng});
}
