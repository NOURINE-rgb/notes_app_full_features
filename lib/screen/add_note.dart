import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:notes/models/note.dart';
import 'package:notes/providers/note_provider.dart';
import 'package:path_provider/path_provider.dart' as syspath;
import 'package:record/record.dart';
import 'package:path/path.dart' as path;

class AddNote extends ConsumerStatefulWidget {
  const AddNote({super.key});
  @override
  ConsumerState<AddNote> createState() {
    return _AddNoteState();
  }
}

class _AddNoteState extends ConsumerState<AddNote> {
  final titleController = TextEditingController();
  final noteController = TextEditingController();
  final AudioRecorder audioRecorder = AudioRecorder();
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  String? fileRecording;
  @override
  void dispose() {
    titleController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void saveData() {
    if (titleController.text.trim().isEmpty ||
        noteController.text.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
            'Invalid input',
            textAlign: TextAlign.start,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          content: Text(
            'please make sure a valid title and text was entered',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: Text(
                'Okey',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ),
          ],
          contentPadding: const EdgeInsets.all(8),
        ),
      );
    } else {
      final note = Note(
          title: titleController.text,
          text: noteController.text,
          recordFile: fileRecording);
      ref.read(notesProvider.notifier).addNote(note);
      Navigator.pop(context);
    }
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
              final appdocumentDir =
                  await syspath.getApplicationDocumentsDirectory();
              final filePath = path.join(appdocumentDir.path, "recording.wav");
              await audioRecorder.start(const RecordConfig(), path: filePath);
              print('funciton*********************');
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
          'Add Note',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: saveData,
                icon: const Icon(
                  Icons.save,
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
            TextField(
              maxLength: 50,
              controller: titleController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Title',
                labelStyle: Theme.of(context).textTheme.bodyLarge,
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
