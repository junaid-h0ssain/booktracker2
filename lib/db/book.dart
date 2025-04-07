import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Book {
  final int? id;
  final String title;
  final String author;
  final String genre;
  final String dateAdded;
  final String status; 

  Book({
    this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.dateAdded,
    this.status = "Reading", // Default value set at the beginning of each entry
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'genre': genre,
      'dateAdded': dateAdded,
      'status': status,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      genre: map['genre'],
      dateAdded: map['dateAdded'],
      status: map['status'] ?? "Completed",
    );
  }

  Book copyWith({String? title, String? author, String? genre, String? status}) {
    return Book(
      id: id,
      title: title ?? this.title,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      dateAdded: dateAdded,
      status: status ?? this.status,
    );
  }
}

class BookDatabase {
  static final BookDatabase instance = BookDatabase._init();

  static Database? _database;

  BookDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('books.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }


  Future<void> _createDB(Database db, int version) async {
      const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
      const textType = 'TEXT NOT NULL';

      await db.execute('''
        CREATE TABLE books (
          id $idType,
          title $textType,
          author $textType,
          genre $textType,
          dateAdded $textType,
          status $textType
        )
      ''');
  }

  Future<Book> create(Book book) async {
  final db = await instance.database;
  // ignore: unused_local_variable
  final id = await db.insert('books', book.toMap());
  return book.copyWith(title: book.title, author: book.author, genre: book.genre);
}


  Future<List<Book>> readAllBooks() async {
    final db = await instance.database;
    final orderBy = 'id ASC';
    final result = await db.query('books', orderBy: orderBy);
    return result.map((map) => Book.fromMap(map)).toList();
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('books', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> update(Book book) async {
    final db = await instance.database;
    return db.update(
      'books',
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}


