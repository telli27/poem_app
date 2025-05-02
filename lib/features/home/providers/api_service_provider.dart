import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poemapp/services/api_service.dart';

// Provider for the ApiService
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});
