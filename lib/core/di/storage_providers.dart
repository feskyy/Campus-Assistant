import 'package:campus_assistant/core/data/app_settings.dart';
import 'package:campus_assistant/core/data/local_store.dart';
import 'package:campus_assistant/core/domain/local_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localStoreProvider = Provider<LocalStore>(
  (ref) => testStoreFor(ref.watch(sharedPreferencesProvider)),
);
