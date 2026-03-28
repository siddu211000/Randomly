import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/app_log.dart';

/// Logs uncaught BLoC errors in debug; register with [Bloc.observer].
final class AppBlocObserver extends BlocObserver {
  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    AppLog.e(
      'Bloc error in ${bloc.runtimeType}',
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }
}
