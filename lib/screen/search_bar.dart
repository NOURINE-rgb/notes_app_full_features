import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/models/note.dart';
import 'package:notes/providers/note_provider.dart';
import 'package:notes/screen/update_note.dart';

class CustomSearch extends ConsumerStatefulWidget {
  const CustomSearch({super.key});
  @override
  ConsumerState<CustomSearch> createState() {
    return _CustomSearchState();
  }
}

class _CustomSearchState extends ConsumerState<CustomSearch> {
  final TextEditingController _controller = TextEditingController();
  List<Note> filteredNotes = [];
  bool varText = false;
  late List<Note> tempList;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void searchQuery(String query) {
    varText = query.isNotEmpty;
    query = query.toLowerCase();
    if (query.trim().isEmpty) {
      filteredNotes = [];
    } else {
      filteredNotes = tempList.where((element) {
        String title = element.title.toLowerCase();
        print(query);
        print(title);
        return title.contains(query);
      }).toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    tempList = ref.watch(notesProvider);
    int i = 0;
    // i will fix the index later
    Widget content = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        // mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 150,
          ),
          Image.asset(
            'assets/images/pixeltrue-seo.png',
            width: 300,
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            varText ? 'Not found ...!' : 'Search ...',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
    if (filteredNotes.isNotEmpty) {
      content = ListView.builder(
        itemCount: filteredNotes.length,
        itemBuilder: (context, index) => ListTile(
          onTap: () {
            for (int j = 0; j < tempList.length; j++) {
              if (tempList[j] == filteredNotes[index]) {
                i = j;
                break;
              }
            }
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => UpdateNote(filteredNotes[index], i),
              ),
            );
          },
          title: Text(
            filteredNotes[index].title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          subtitle: Text(
            filteredNotes[index].formmatedDate,
            style: const TextStyle(
                color: Colors.white38, fontWeight: FontWeight.w300),
          ),
          leading: Container(
            width: 37,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: tempList[index].color,
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        actions: [
          const SizedBox(
            width: 60,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 10, top: 6, bottom: 6),
              child: TextField(
                controller: _controller,
                maxLines: 1,
                // maxLength: 50,
                // style: TextStyle(color: Colors.white),
                cursorColor: Colors.grey,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: _controller.clear,
                    icon: const Icon(
                      Icons.cancel,
                      color: Colors.grey,
                    ),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  hintText: 'Search notes ...',
                  // hintStyle: TextStyle(color:Theme.of(context)),
                  // focusColor: Colors.blue,
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: searchQuery,
              ),
            ),
          ),
        ],
      ),
      body: content,
    );
  }
}
