import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReversedProviderNotifier extends StateNotifier<bool> {
  ReversedProviderNotifier() : super(false);
  bool reverse() {
    state = !state;
    return state;
  }
}

final isReversedProvider =
    StateNotifierProvider<ReversedProviderNotifier, bool>(
  (ref) => ReversedProviderNotifier(),
);
