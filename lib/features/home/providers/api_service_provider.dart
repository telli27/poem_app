import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poemapp/services/api_service.dart';

// Create a singleton instance of ApiService
final _apiServiceInstance = ApiService();

// Provider for the ApiService - singleton instance
final apiServiceProvider = Provider<ApiService>((ref) {
  return _apiServiceInstance;
});
