import 'package:flutter/material.dart';
import 'package:booktracker/pages/settings.dart';
import 'package:booktracker/pages/library.dart';
import 'package:booktracker/db/book.dart';
import 'package:intl/intl.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  _BookListScreenState createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  List<Book> books = [];

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final loadedBooks = await BookDatabase.instance.readAllBooks();
    //print("Loaded books count: ${loadedBooks.length}"); // Debug print
    setState(() {
      books = loadedBooks;
    });
  }

  Future<void> _showAddBookDialog() async {
    TextEditingController titleController = TextEditingController();
    TextEditingController authorController = TextEditingController();
    TextEditingController genreController = TextEditingController();
    //String dateAdded = DateTime.now().toLocal().toString(); // e.g., 2025-02-18
    String dateAdded = DateFormat('dd/MM/yyyy hh:mm:ss').format(DateTime.now());

    final String? newBookDetails = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Books"),
          content: SingleChildScrollView( 
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Book Title"),
                ),
                TextField(
                  controller: authorController,
                  decoration: const InputDecoration(labelText: "Author Name"),
                ),
                TextField(
                  controller: genreController,
                  decoration: const InputDecoration(labelText: "Genre"),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text("Date: $dateAdded"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                String title = titleController.text.trim();
                String author = authorController.text.trim();
                String genre = genreController.text.trim();

                if (title.isNotEmpty && author.isNotEmpty && genre.isNotEmpty) {
                  Navigator.of(context).pop("$title|$author|$genre");
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );

    if (newBookDetails != null) {
      List<String> details = newBookDetails.split("|");
      Book newBook = Book(
        title: details[0],
        author: details[1],
        genre: details[2],
        dateAdded: dateAdded,
      );

      final createdBook = await BookDatabase.instance.create(newBook);
      setState(() {
        books.add(createdBook);
      });
    }
  }

  Future<void> _editBook(Book book) async {
    TextEditingController titleController = TextEditingController(text: book.title);
    TextEditingController authorController = TextEditingController(text: book.author);
    TextEditingController genreController = TextEditingController(text: book.genre);

    final String? updatedDetails = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Book"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: "Book Title"),
                  ),
                  TextField(
                    controller: authorController,
                    decoration: const InputDecoration(labelText: "Author Name"),
                  ),
                  TextField(
                    controller: genreController,
                    decoration: const InputDecoration(labelText: "Genre"),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text("Date: ${book.dateAdded}"),
                  ),
                ],
              ),
            ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                String title = titleController.text.trim();
                String author = authorController.text.trim();
                String genre = genreController.text.trim();

                if (title.isNotEmpty && author.isNotEmpty && genre.isNotEmpty) {
                  Navigator.of(context).pop("$title|$author|$genre");
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );

    if (updatedDetails != null) {
      List<String> details = updatedDetails.split("|");
      Book updatedBook = book.copyWith(
        title: details[0],
        author: details[1],
        genre: details[2],
      );
      await BookDatabase.instance.update(updatedBook);
      _loadBooks(); 
    }
  }

  Future<void> _deleteBook(int id) async {
    await BookDatabase.instance.delete(id);
    setState(() {
      books.removeWhere((book) => book.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 166, 240, 92),
      appBar: AppBar(
        title: Center(
          child: const Text(
            "Book Tracker",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 246, 119, 162),
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          },
          icon: const Icon(Icons.settings),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LibPage()),
            );
            },
            icon: const Icon(Icons.library_books),
          )
        ],
      ),
      body: books.isEmpty
          ? const Center(
              child: Text(
                "No books added yet",
                style: TextStyle(fontSize: 18,
                fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return Card(
                  child: ListTile(
                    title: Text(book.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Author: ${book.author}\n"
                          "Genre: ${book.genre}\n"
                          "Added on: ${book.dateAdded}",
                        ),
                        const SizedBox(height: 5),
                        DropdownButton<String>(
                          value: book.status,
                          items: const [
                            DropdownMenuItem(
                              value: "Reading",
                              child: Text("Reading"),
                            ),
                            DropdownMenuItem(
                              value: "Completed",
                              child: Text("Completed"),
                            ),
                            DropdownMenuItem(
                              value: "Plan to Read",
                              child: Text("Plan to Read"),
                            ),
                          ],
                          onChanged: (String? newStatus) async {
                            if (newStatus != null && newStatus != book.status) {
                              Book updatedBook = book.copyWith(status: newStatus);
                              await BookDatabase.instance.update(updatedBook);
                              _loadBooks(); 
                            }
                          },
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editBook(book),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteBook(book.id!),
                        ),
                      ],
                    ),
                  ),
                );

              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 246, 119, 162),
        onPressed: _showAddBookDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
