import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:notes/models/note.dart';
import 'package:notes/providers/note_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:path/path.dart' as p;

class UpdateNote extends ConsumerStatefulWidget {
  const UpdateNote(this.note, this.index, {super.key});
  final Note note;
  final int index;
  @override
  ConsumerState<UpdateNote> createState() {
    return _UpdateNoteState();
  }
}

class _UpdateNoteState extends ConsumerState<UpdateNote> {
  @override
  void initState() {
    super.initState();
    noteController.text = widget.note.text;
    fileRecording = widget.note.recordFile;
  }

  final noteController = TextEditingController();
  final AudioRecorder audioRecorder = AudioRecorder();
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  String? fileRecording;
  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  void saveData() {
    if (noteController.text.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Invalid input'),
          content: Text(
            'please make sure a valid text was entered',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Colors.black12,
                  fontWeight: FontWeight.normal,
                ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Okey'),
            ),
          ],
          contentPadding: const EdgeInsets.all(8),
        ),
      );
    }
    print('test 1 in the updatescreen to create note updated');
    final note = Note(
        id: widget.note.id,
        color: widget.note.color,
        date: widget.note.date,
        title: widget.note.title,
        text: noteController.text,
        recordFile: fileRecording);
    ref.read(notesProvider.notifier).update(note, widget.index);
    Navigator.pop(context);
  }

  void playingAudio() async {
    if (audioPlayer.playing) {
      audioPlayer.stop();
      setState(() {
        isPlaying = false;
      });
    } else {
      await audioPlayer.setFilePath(fileRecording!);
      setState(() {
        isPlaying = true;
      });
      await audioPlayer.play();
      setState(() {
        isPlaying = false;
      });
    }
  }

  bool isRecording = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (isRecording) {
            String? recordingFile = await audioRecorder.stop();
            if (recordingFile != null) {
              setState(() {
                isRecording = false;
                fileRecording = recordingFile;
              });
            }
          } else {
            if (await audioRecorder.hasPermission()) {
              final appdocumentDir = await getApplicationDocumentsDirectory();
              final filePath = p.join(appdocumentDir.path, "recording.wav");
              await audioRecorder.start(const RecordConfig(), path: filePath);
              setState(() {
                isRecording = true;
                fileRecording = null;
              });
            }
          }
        },
        shape: const CircleBorder(),
        child: Icon(
          isRecording ? Icons.stop : Icons.keyboard_voice,
        ),
      ),
      appBar: AppBar(
        title: Text(
          widget.note.title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: saveData,
                icon: const Icon(
                  Icons.save_alt,
                  size: 26,
                ),
              ),
            ],
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            SizedBox(
              height: 100,
              width: double.infinity,
              child: fileRecording == null
                  ? Center(
                      child: Text(
                        "No recording added yet",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                  : TextButton.icon(
                      onPressed: playingAudio,
                      icon: !isPlaying
                          ? const Icon(
                              Icons.arrow_right_outlined,
                              size: 30,
                            )
                          : const Icon(
                              Icons.stop,
                              size: 30,
                            ),
                      label: !isPlaying
                          ? Text(
                              'Start audio',
                              style: Theme.of(context).textTheme.bodyLarge,
                            )
                          : Text(
                              'Stop audio',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                    ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: TextField(
                  maxLines: null,
                  controller: noteController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(16),
                    border: const OutlineInputBorder(),
                    label: Text(
                      'write here...',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
