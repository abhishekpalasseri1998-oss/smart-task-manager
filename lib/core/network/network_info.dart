import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<List<ConnectivityResult>> get onConnectivityChanged;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfoImpl({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;
}

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl();
});

final connectivityStreamProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return ref.watch(networkInfoProvider).onConnectivityChanged;
});

final isOnlineProvider = Provider<bool>((ref) {
  final connectivityAsync = ref.watch(connectivityStreamProvider);
  return connectivityAsync.maybeWhen(
    data: (results) => !results.contains(ConnectivityResult.none),
    orElse: () => true, // Assume online until connectivity check resolves
  );
});
