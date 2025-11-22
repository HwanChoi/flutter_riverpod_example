import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/board.dart';

import '../providers/auth_provider.dart';

final boardListProvider = FutureProvider<List<Board>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getBoards();
});
