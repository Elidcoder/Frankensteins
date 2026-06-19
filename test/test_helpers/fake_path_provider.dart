// Test double for path_provider. Install in setUpAll with:
//   PathProviderPlatform.instance = FakePathProvider(tempDir.path);
//
// Returns the configured base path for every directory query so tests can
// point JsonStorageService at a disposable temp directory.
import "package:path_provider_platform_interface/path_provider_platform_interface.dart";
import "package:plugin_platform_interface/plugin_platform_interface.dart";

class FakePathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  final String basePath;

  FakePathProvider(this.basePath);

  @override
  Future<String?> getApplicationDocumentsPath() async => basePath;

  @override
  Future<String?> getApplicationSupportPath() async => basePath;

  @override
  Future<String?> getTemporaryPath() async => basePath;

  @override
  Future<String?> getDownloadsPath() async => basePath;
}
