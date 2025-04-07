import 'package:flutter/material.dart';
import 'package:booktracker/db/book.dart';

class LibPage extends StatefulWidget {
  const LibPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LibPageState createState() => _LibPageState();
}

class _LibPageState extends State<LibPage> {
  List<Book> books = [];

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final loadedBooks = await BookDatabase.instance.readAllBooks();
    setState(() {
      books = loadedBooks;
    });
  }

  @override
  Widget build(BuildContext context) {
    // String link="";
    // TextEditingController linkController = TextEditingController(text:link);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 46, 171, 35),
      appBar: AppBar(
        title: const Text("Library"),
        backgroundColor: const Color.fromARGB(255, 246, 119, 162),
      ),
      body: books.isEmpty
          ? const Center(
              child: Text(
                "No books added yet",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            )
          : SingleChildScrollView(
            
              scrollDirection: Axis.vertical, 
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 40.3,
                  border: TableBorder.all(color: Colors.black26), 
                  columns: const [
                    DataColumn(label: Text("Title")),
                    DataColumn(label: Text("Author")),
                    DataColumn(label: Text("Genre")),
                    DataColumn(label: Text("Date Added")),
                    //DataColumn(label: Text("Link")),
                  ],
                  rows: books.map((book) {
                    return DataRow(cells: [
                      DataCell(Text(book.title)),
                      DataCell(Text(book.author)),
                      DataCell(Text(book.genre)),
                      DataCell(Text(book.dateAdded)),
                      // DataCell(
                      //   TextField(
                      //     controller: linkController,
                      //     onSubmitted: (newLink) async {
                      //       Text(link);
                      //     },
                      //   ),
                      // ),
                    ]);
                  }).toList(),
                ),
              ),
            ),
    );
  }
}
