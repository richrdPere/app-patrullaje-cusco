enum TrackingTransmissionStatus {
  /// El tracking todavía no ha intentado transmitir.
  idle,

  /// El tracking está activo, pero todavía no se obtuvo
  /// una ubicación.
  waitingLocation,

  /// Se está enviando una ubicación al servidor.
  sending,

  /// El servidor confirmó que la ubicación fue recibida.
  transmitted,

  /// El servidor recibió la ubicación, pero no la guardó
  /// porque no existía desplazamiento significativo.
  omitted,

  /// Ubicación guardada en SQLite.
  storedOffline,

  /// Ubicaciones pendientes siendo enviadas.
  synchronizing,

  /// La ubicación no pudo enviarse o confirmarse.
  failed,
}
