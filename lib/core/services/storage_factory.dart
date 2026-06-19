import 'package:frankenstein/core/services/storage_service.dart';

// Conditional import: the web build (`dart.library.js_interop`) gets the
// localStorage-backed factory, every other platform gets the file-backed one.
// This is what keeps `dart:io` (pulled in by JsonStorageService) out of the
// web compilation, which would otherwise fail to compile.
import 'storage_factory_io.dart'
    if (dart.library.js_interop) 'storage_factory_web.dart' as impl;

/// Returns the appropriate [StorageService] for the current platform.
StorageService createStorageService() => impl.createStorageService();
