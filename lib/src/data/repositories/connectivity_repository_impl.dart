import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sis_patrullaje_cusco/src/data/datasources/remote/services/connectivity_service.dart';

class ConnectivityServiceImpl implements ConnectivityService {
  final Connectivity connectivity;

  ConnectivityServiceImpl({required this.connectivity});

  @override
  Stream<bool> get connectionChanges {
    return connectivity.onConnectivityChanged
        .map((results) => !results.contains(ConnectivityResult.none))
        .distinct();
  }

  @override
  Future<bool> hasConnection() async {
    final results = await connectivity.checkConnectivity();

    return !results.contains(ConnectivityResult.none);
  }
}
