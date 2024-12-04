import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/models/note.dart';
import 'package:notes/providers/note_provider.dart';
import 'package:notes/widget/list_notes.dart';

class AnimatedSliver extends ConsumerStatefulWidget {
  const AnimatedSliver({
    super.key,
    required this.isReversed,
    required this.isSelectedMode,
    required this.selectedItems,
  });
  final bool isReversed;
  final bool isSelectedMode;
  final List<bool> selectedItems;
  @override
  ConsumerState<AnimatedSliver> createState() {
    return _AnimatedSliverState();
  }
}

class _AnimatedSliverState extends ConsumerState<AnimatedSliver> {
  // late Future<void> _notesUser;
  @override
  void initState() {
    super.initState();
       ref.read(notesProvider.notifier).loadDatabase();
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(notesProvider);
    List<Note> reversedItems = items.reversed.toList();
    return SliverList(
            delegate: SliverChildBuilderDelegate(                
                (context, index) => Container(
                
                      height: 60,
                      padding:
                          const EdgeInsets.only(top: 8, right: 8, bottom: 8),
                      child: !widget.isReversed
                          ? ListNotes(
                              notes: items[index],
                              isSelectedMOde: widget.isSelectedMode,
                              selectedItems: widget.selectedItems,
                              index: index,
                            )
                          : ListNotes(
                              notes: reversedItems[index],
                              isSelectedMOde: widget.isSelectedMode,
                              selectedItems: widget.selectedItems,
                              index: index,
                            ),
                    ),
                childCount: items.length),
          );
  }
}
