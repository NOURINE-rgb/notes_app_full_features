import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:notes/models/note.dart';
import 'package:notes/providers/mode_provider.dart';
import 'package:notes/providers/number_provider.dart';
import 'package:notes/screen/update_note.dart';

class ListNotes extends ConsumerStatefulWidget {
  const ListNotes(
      {required this.notes,
      required this.selectedItems,
      required this.isSelectedMOde,
      required this.index,
      super.key});
  final Note notes;
  final int index;
  final bool isSelectedMOde;
  final List<bool> selectedItems;

  @override
  ConsumerState<ListNotes> createState() => _ListNotesState();
}

List<bool>? listSelected;
int? indexGlobal;

class _ListNotesState extends ConsumerState<ListNotes> {
  AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  void playVoice() async {
    if (audioPlayer.playing) {
      audioPlayer.stop();
      setState(() {
        isPlaying = false;
      });
    } else {
      await audioPlayer.setFilePath(widget.notes.recordFile!);
      setState(() {
        isPlaying = true;
      });
      await audioPlayer.play();
      setState(() {
        isPlaying = false;
      });
    }
  }

  void longPress() {
    if (widget.isSelectedMOde) {
      return;
    } else {
      ref.read(isSelectedProvider.notifier).reverse(!widget.isSelectedMOde);
      ref.read(numberProvider.notifier).increase(1);
      if (!widget.isSelectedMOde) {
        indexGlobal = widget.index;
      }
    }
  }

  bool valueFun(int index) {
    indexGlobal = null;
    widget.selectedItems[index] = true;
    listSelected  = widget.selectedItems;
    return widget.selectedItems[index];
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onLongPress: () {
        longPress();
      },
      onTap: () => widget.isSelectedMOde
          ? null
          : Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UpdateNote(
                  widget.notes,
                  widget.index,
                ),
              ),
            ),
      title: Text(
        widget.notes.title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      subtitle: Text(
        widget.notes.formmatedDate,
        style:
             TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w300),
      ),
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.isSelectedMOde)
            Checkbox(
                value: indexGlobal == widget.index
                    ? valueFun(widget.index)
                    : widget.selectedItems[widget.index],
                checkColor: Theme.of(context).colorScheme.background,
                activeColor: Theme.of(context).colorScheme.onPrimary,
                onChanged: (value) {
                  setState(() {
                    widget.selectedItems[widget.index] = value!;
                  });
                  listSelected = widget.selectedItems;
                  if (value!) {
                    ref.read(numberProvider.notifier).increase(1);
                  } else {
                    ref.read(numberProvider.notifier).increase(-1);
                  }
                }),
          Container(
            width: 37,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: widget.notes.color,
            ),
          ),
        ],
      ),
      trailing: widget.notes.recordFile == null
          ? null
          : IconButton(
              onPressed: playVoice,
              icon: Icon(
                isPlaying ? Icons.stop : Icons.play_arrow,
                // color: Theme.of(context).colorScheme.b,
              ),
            ),
    );
  }
}
