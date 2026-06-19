import 'package:frankenstein/core/services/storage_service.dart';
import 'package:frankenstein/core/services/web_storage_service.dart';

/// Web: localStorage-backed storage via shared_preferences.
StorageService createStorageService() => WebStorageService();
