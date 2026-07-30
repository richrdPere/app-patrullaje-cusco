import 'package:sis_patrullaje_cusco/src/data/datasources/local/models/offline_incident_file_input.dart';
import 'package:sis_patrullaje_cusco/src/data/datasources/local/models/offline_incident_input.dart';

// import '../database/offline_database.dart';

class OfflineIncidentWithFiles {
  final OfflineIncidentInput incident;
  final List<OfflineIncidentFileInput> files;

  const OfflineIncidentWithFiles({required this.incident, required this.files});
}
