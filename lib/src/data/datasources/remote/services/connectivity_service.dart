abstract class ConnectivityService {
  Stream<bool> get connectionChanges;

  Future<bool> hasConnection();
}
