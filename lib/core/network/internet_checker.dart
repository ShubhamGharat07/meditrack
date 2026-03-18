import 'package:connectivity_plus/connectivity_plus.dart';

class InternetChecker {
  final Connectivity _connectivity = Connectivity();

  // Ek baar check karo — internet hai ya nahi
  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result.first != ConnectivityResult.none;
  }

  // Stream — jab bhi internet aaye ya jaaye notify karo
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(
      (result) => result.first != ConnectivityResult.none,
    );
  }
}
