import 'package:frankenstein/core/services/json_storage_service.dart';
import 'package:frankenstein/core/services/storage_service.dart';

/// Desktop/mobile: file-backed storage under the app documents directory.
StorageService createStorageService() => JsonStorageService();
