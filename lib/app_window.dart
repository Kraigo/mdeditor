import 'package:flutter/services.dart';

/// Requests the host platform to close the application.
///
/// Used when the last open document tab is closed (per requirements: closing
/// all tabs closes the app).
void closeApp() {
  SystemNavigator.pop();
}
