import 'dart:math';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

final formatter = DateFormat.yMMMd();
const uid = Uuid();

class Note {
  Note({String? id,Color? color ,DateTime? date,required this.title, required this.text, this.recordFile})
      : id = id ?? uid.v4(),
        date = date ?? DateTime.now(),
        color = color ?? Color.fromARGB(
                255,
                Random().nextInt(256),
                Random().nextInt(256),
                Random().nextInt(256),
              ).withOpacity(0.4);
  final String id;
  final String title;
  final String text;
  final DateTime date;
  
  final String? recordFile;
  final Color color;
  String get sqlDate{
    return date.toString();
  }
  String get formmatedDate {
    return formatter.format(date);
  }
}
