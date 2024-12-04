import 'package:flutter_riverpod/flutter_riverpod.dart';

class NumberProviderNotifier extends StateNotifier<int> {
  NumberProviderNotifier() : super(0);

  void increase(int value) {
    state = state + value;
  }

  void all(int value) {
    state = value;
  }

  void reset() {
    state = 0;
  }
}

final numberProvider = StateNotifierProvider<NumberProviderNotifier, int>(
  (ref) {
    print('loading the number of items selected');
    return NumberProviderNotifier();
  },
);
