import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/main.dart';
import 'package:notes/providers/note_provider.dart';
import 'package:notes/providers/number_provider.dart';
import 'package:notes/providers/reversed.dart';
import 'package:notes/providers/mode_provider.dart';
import 'package:notes/providers/theme_change.dart';
import 'package:notes/screen/add_note.dart';
import 'package:notes/screen/search_bar.dart';
import 'package:notes/widget/animted_sliver.dart';
import 'package:notes/widget/list_notes.dart';
import 'package:rive/rive.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final _scrollController = ScrollController();
  String titleAppBar = "Selected";
  bool isButtonVisible = true;
  bool buttonScrollUp = false;
  bool isReversed = false;
  bool isCheckedAll = false;
  StateMachineController? controller;
  SMIInput<bool>? switchInput;
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!buttonScrollUp) {
        setState(() {
          buttonScrollUp = true;
        });
      }
      if (!isButtonVisible) {
        setState(() {
          isButtonVisible = true;
        });
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (isButtonVisible) {
        setState(() {
          isButtonVisible = false;
          buttonScrollUp = true;
        });
      }
    }

    _scrollController.position.isScrollingNotifier.addListener(() async {
      if (!_scrollController.position.isScrollingNotifier.value &&
          !isButtonVisible) {
        setState(() {
          isButtonVisible = true;
        });
      }
      if (!_scrollController.position.isScrollingNotifier.value &&
          buttonScrollUp) {
        await Future.delayed(
          const Duration(seconds: 3),
        );
        setState(() {
          buttonScrollUp = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool trueOrFalse = false;
  bool isLightMode = false;
  late List<bool> selectedItems;

  void deletedItems(bool isSelectedMode) {
    listSelected = null;
    ref.read(numberProvider.notifier).reset();
    ref.read(notesProvider.notifier).deleteItems(selectedItems);
    ref.read(isSelectedProvider.notifier).reverse(!isSelectedMode);
  }

  @override
  Widget build(BuildContext context) {
    final length = ref.watch(notesProvider).length;
    int numberOfSelected = ref.watch(numberProvider);
    if (listSelected != null) {
      selectedItems = listSelected!;
    } else {
      trueOrFalse
          ? selectedItems = List<bool>.filled(length, true)
          : selectedItems = List<bool>.filled(length, false);
    }
    final isSelectedMode = ref.watch(isSelectedProvider);
    void goTop() {
      _scrollController.animateTo(0.0,
          duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
    }

    return Scaffold(
      floatingActionButton: isSelectedMode
          ? FloatingActionButton(
              onPressed: () => deletedItems(isSelectedMode),
              child: const Icon(Icons.delete),
            )
          : null,
      body: Scrollbar(
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                isSelectedMode
                    ? SliverAppBar(
                        backgroundColor:
                            Theme.of(context).colorScheme.background,
                        pinned: true,
                        expandedHeight: 200,
                        actions: [
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isCheckedAll,
                                  checkColor:
                                      Theme.of(context).colorScheme.background,
                                  shape: const CircleBorder(),
                                  activeColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  onChanged: (value) {
                                    value!
                                        ? ref
                                            .read(numberProvider.notifier)
                                            .all(selectedItems.length)
                                        : ref
                                            .read(numberProvider.notifier)
                                            .all(0);
                                    listSelected = List<bool>.filled(
                                        selectedItems.length, value);
                                    setState(() {
                                      trueOrFalse = value;
                                      isCheckedAll = value;
                                    });
                                  },
                                ),
                                const Text(
                                  'all',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal),
                                ),
                                const SizedBox(
                                  width: 278,
                                ),
                                IconButton(
                                    onPressed: () {
                                      trueOrFalse = false;
                                      isCheckedAll = false;
                                      listSelected = null;
                                      ref.read(numberProvider.notifier).reset();
                                      ref
                                          .read(isSelectedProvider.notifier)
                                          .reverse(!isSelectedMode);
                                    },
                                    icon: const Icon(Icons.arrow_back))
                              ],
                            ),
                          ),
                        ],
                        flexibleSpace: FlexibleSpaceBar(
                          title: Text(
                            numberOfSelected == 0
                                ? 'Select notes'
                                : '$numberOfSelected $titleAppBar',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          centerTitle: true,
                        ),
                      )
                    : SliverAppBar(
                        backgroundColor:
                            Theme.of(context).colorScheme.background,
                        pinned: true,
                        expandedHeight: 200,
                        actions: [
                          Row(
                            children: [
                              // i will be here soon

                              GestureDetector(
                                onTap: () {
                                  if (switchInput == null) {
                                    print("the switch input is null");
                                    return;
                                  }
                                  final isDark = switchInput!.value;
                                  ref.read(themeProvider.notifier).change();
                                  switchInput!.change(!isDark);
                                },
                                child: SizedBox(
                                  width: 70,
                                  height: 50,
                                  child: RiveAnimation.asset(
                                    'assets/animation/switch_theme.riv',
                                    fit: BoxFit.fill,
                                    stateMachines: const ["Switch Theme"],
                                    onInit: (artboard) {
                                      controller =
                                          StateMachineController.fromArtboard(
                                              artboard, "Switch Theme");
                                      if (controller == null) {
                                        print(
                                            "the controller is null*********");
                                        return;
                                      }

                                      artboard.addController(controller!);
                                      switchInput =
                                          controller!.findInput('isDark');
                                      final mode = ref.watch(themeProvider);
                                      print("$mode ***********");
                                      switchInput!.change(mode == themeDark);
                                      print(
                                          "${switchInput!.value} this the value of swithc input *************");
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 220,
                              ),
                              IconButton(
                                onPressed: () {
                                  ref
                                      .read(isReversedProvider.notifier)
                                      .reverse();
                                  setState(() {
                                    isReversed = !isReversed;
                                  });
                                },
                                icon: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Icon(
                                    !isReversed
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    key: ValueKey(isReversed),
                                    size: 30,
                                  ),
                                  transitionBuilder: (child, animation) =>
                                      RotationTransition(
                                    turns: Tween<double>(begin: 0.5, end: 1)
                                        .animate(animation),
                                    child: child,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 9,
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CustomSearch(),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.search,
                                  size: 32,
                                ),
                              ),
                            ],
                          ),
                        ],
                        flexibleSpace: FlexibleSpaceBar(
                          title: Text(
                            'All notes',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          centerTitle: true,
                        ),
                      ),
                AnimatedSliver(
                  isReversed: isReversed,
                  isSelectedMode: isSelectedMode,
                  selectedItems: selectedItems,
                ),
              ],
            ),
            if (!isSelectedMode)
              Positioned(
                bottom: 40,
                right: 20,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isButtonVisible ? 1 : 0,
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddNote(),
                        ),
                      );
                    },
                    shape: const CircleBorder(),
                    child: const Icon(Icons.edit_document),
                  ),
                ),
              ),
            if (!isSelectedMode)
              Positioned(
                left: 185,
                right: 185,
                bottom: 32,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: buttonScrollUp ? 1 : 0,
                  child: FloatingActionButton(
                    onPressed: goTop,
                    shape: const CircleBorder(),
                    backgroundColor: Colors.white10,
                    foregroundColor: Colors.white30,
                    child: const Icon(Icons.arrow_upward),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
