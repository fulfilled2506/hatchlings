import 'package:flutter/widgets.dart';

import 'app.dart';
import 'data/content_catalog.dart';
import 'data/save_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final catalog = await ContentCatalog.loadFromAssets();
  final save = SaveRepository(SharedPrefsSaveStore());
  runApp(HatchlingsApp(catalog: catalog, save: save));
}
