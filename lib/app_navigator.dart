import 'package:flutter/widgets.dart';

/// Root navigator key, used to show dialogs from outside the widget tree
/// (e.g. the quit-confirmation triggered by the native channel).
final navigatorKey = GlobalKey<NavigatorState>();
