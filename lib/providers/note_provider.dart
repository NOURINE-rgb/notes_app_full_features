import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/models/note.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';
import 'package:sqflite/sqflite.dart' as sql;

class NotesProviderNotifier extends StateNotifier<List<Note>> {
  NotesProviderNotifier() : super([]);
  Future<Database> getDataBase() async {
    print('get a data base************');
    final pathDb = await sql.getDatabasesPath();
    final db = await sql.openDatabase(
      path.join(pathDb, "notes.db"),
      onCreate: (db, version) {
        print('excute function *****************');
        return db.execute(
            'Create table notes_user(id text primary key, title text ,note text,filerecord text, date text)');
      },
      version: 1,
    );
    print('finish getting the database path ******');
    return db;
  }

  Future<void> loadDatabase() async {
    final db = await getDataBase();
    print('loading a database ************');
    final data = await db.query('notes_user');
    final places = data.map(
      (row) {
        return Note(
          id: row['id'] as String,
          title: row['title'] as String,
          text: row['note'] as String,
          date: DateTime.parse(row['date'] as String),
          recordFile:
              row['filerecord'] == null ? null : row['filerecord'] as String,
        );
      },
    ).toList();
    state = places;
  }

  void addNote(Note note) async {
    state = [note, ...state];
    final Database db = await getDataBase();
    print('add a database*************');
    db.insert('notes_user', {
      'id': note.id,
      'title': note.title,
      'note': note.text,
      'filerecord': note.recordFile,
      'date': note.date.toString(),
    });
    print('finish adding the item *********');
  }

  void update(Note note, int index) async {
    state[index] = note;
    state = [...state, note];
    state = state.sublist(0, state.length - 1);
    final db = await getDataBase();
    db.update(
      'notes_user',
      {
        'id': note.id,
        'title': note.title,
        'note': note.text,
        'filerecord': note.recordFile,
        'date': note.date.toString(),
      },
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  void deleteItems(List<bool> deletedItems) async {
    int i = -1;
    List<Note> tempList = [];
    state = state.where((element) {
      i++;
      if (deletedItems[i]) {
        tempList = [...tempList, element];
      }
      return !deletedItems[i];
    }).toList();
    final db = await getDataBase();
    for (i = 0; i < deletedItems.length; i++) {
      db.delete(
        'notes_user',
        where: 'id = ?',
        whereArgs: [tempList[i].id],
      );
    }
  }
}

final notesProvider = StateNotifierProvider<NotesProviderNotifier, List<Note>>(
  (ref) {
    print('loading the items from riverpod note_provider');
    return NotesProviderNotifier();
  },
);
