import 'package:flutter_driver/driver_extension.dart';
import 'package:project_finder/main.dart' as app;

void main() {
  enableFlutterDriverExtension(handler: (command) async {
    switch (command) {
      case 'restart':
        app.main();
        return 'ok';
    }
    throw Exception('Unknown command');
  });
  app.main();
}
