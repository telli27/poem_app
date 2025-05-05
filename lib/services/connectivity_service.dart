import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:poemapp/features/home/providers/poet_provider.dart';

enum ConnectionStatus { online, offline, weak }

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamController<ConnectionStatus> connectionStatusController =
      StreamController<ConnectionStatus>.broadcast();

  // Track the previous connection status to show toast only on status changes
  // and to detect when connection is restored
  ConnectionStatus? _previousStatus;

  // Reference to the ProviderRef to access other providers
  final ProviderRef? _ref;

  Timer? _periodicCheckTimer;

  // Debounce timer to prevent multiple rapid reloads
  Timer? _reloadDebounceTimer;

  // Flag to track if we're currently reloading data
  bool _isReloadingData = false;

  ConnectivityService(this._ref) {
    // Initialize the connectivity stream
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    // Check connection status at startup
    checkConnectivity();
    // Start periodic check
    startPeriodicCheck();
  }

  // Check current connectivity
  Future<void> checkConnectivity() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      await _updateConnectionStatus(connectivityResult);
    } catch (e) {
      _updateConnectionStatusAndNotify(ConnectionStatus.offline);
    }
  }

  // Update connection status and test internet quality
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    if (result == ConnectivityResult.none) {
      _updateConnectionStatusAndNotify(ConnectionStatus.offline);
      return;
    }

    // Test if there's actual internet connection and its quality
    try {
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        // Check connection speed by measuring response time
        final connectionDelay = await _testConnectionSpeed();
        if (connectionDelay > 1500) {
          // If response time is more than 1.5 seconds, consider it a weak connection
          _updateConnectionStatusAndNotify(ConnectionStatus.weak);
        } else {
          _updateConnectionStatusAndNotify(ConnectionStatus.online);
        }
      } else {
        _updateConnectionStatusAndNotify(ConnectionStatus.weak);
      }
    } catch (e) {
      _updateConnectionStatusAndNotify(ConnectionStatus.offline);
    }
  }

  // Update status and show toast notification if status changed
  void _updateConnectionStatusAndNotify(ConnectionStatus newStatus) {
    // Show toast if status changed to weak from any other status
    if (newStatus == ConnectionStatus.weak &&
        _previousStatus != ConnectionStatus.weak) {
      _showWeakConnectionToast();
    }

    // Check if connection was restored from offline
    if (_previousStatus == ConnectionStatus.offline &&
        (newStatus == ConnectionStatus.online ||
            newStatus == ConnectionStatus.weak)) {
      // Add debounce to avoid rapid consecutive reloads
      _debounceReload();

      // Show toast that connection is restored and data is being reloaded
      Fluttertoast.showToast(
          msg: "İnternet bağlantısı kuruldu",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.green.shade700,
          textColor: Colors.white,
          fontSize: 16.0);
    }

    // Update the previous status
    _previousStatus = newStatus;

    // Update the stream controller
    connectionStatusController.add(newStatus);
  }

  // Debounce the reload to prevent multiple rapid reloads
  void _debounceReload() {
    // Cancel any pending reload
    _reloadDebounceTimer?.cancel();

    // If we're already reloading, don't trigger another reload
    if (_isReloadingData) return;

    // Set a timer to trigger reload after a short delay
    _reloadDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _triggerDataReload();
    });
  }

  // Trigger data reload when connection is restored
  void _triggerDataReload() {
    if (_ref != null && !_isReloadingData) {
      _isReloadingData = true;

      // Set refreshDataProvider to true to trigger data reload
      try {
        _ref!.read(refreshDataProvider.notifier).state = true;

        // Reset the flag after a delay to allow for future reloads
        Timer(const Duration(seconds: 5), () {
          _isReloadingData = false;
        });
      } catch (e) {
        print("❌ Error triggering data reload: $e");
        _isReloadingData = false;
      }
    }
  }

  // Show toast notification for weak connection
  void _showWeakConnectionToast() {
    Fluttertoast.showToast(
        msg: "İnternet bağlantısı zayıf, veriler yavaş yüklenebilir",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.orange.shade700,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  // Simple function to test connection speed
  Future<int> _testConnectionSpeed() async {
    final stopwatch = Stopwatch()..start();
    try {
      await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 10));
      stopwatch.stop();
      return stopwatch.elapsedMilliseconds;
    } catch (e) {
      stopwatch.stop();
      return 10000; // Assume very slow connection if there's an error
    }
  }

  // Start periodic connectivity check (every 30 seconds)
  void startPeriodicCheck() {
    _periodicCheckTimer?.cancel();
    _periodicCheckTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      checkConnectivity();
    });
  }

  // Stop periodic check
  void stopPeriodicCheck() {
    _periodicCheckTimer?.cancel();
    _periodicCheckTimer = null;
  }

  void dispose() {
    _periodicCheckTimer?.cancel();
    _reloadDebounceTimer?.cancel();
    connectionStatusController.close();
  }

  // Method that can be called from anywhere in the app to check connection
  // and show a toast if connection is weak
  Future<ConnectionStatus> checkConnectionAndNotify() async {
    await checkConnectivity();
    // Force toast to show even if status hasn't changed
    if (_previousStatus == ConnectionStatus.weak) {
      _showWeakConnectionToast();
    }
    return _previousStatus ?? ConnectionStatus.offline;
  }
}

// Provider for the ConnectivityService
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService(ref);
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

// Stream provider for connection status
final connectionStatusProvider = StreamProvider<ConnectionStatus>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return connectivityService.connectionStatusController.stream;
});
