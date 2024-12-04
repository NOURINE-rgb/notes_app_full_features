import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedProviderNotifier extends StateNotifier<bool> {
  SelectedProviderNotifier() : super(false);
  bool reverse(bool value) {
    print('reverse the selectedmode in the selcted_provider file');
    state = value;
    return state;
  }
}

final isSelectedProvider =
    StateNotifierProvider<SelectedProviderNotifier, bool>((ref) {
  return SelectedProviderNotifier();
});
