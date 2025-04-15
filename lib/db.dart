import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'song.dart';
class Helper {
  static Database? _database;

  Future<Database?> get database async {
    if (_database == null) {
      _database = await _initDb();
      return _database;
    } else {
      return _database!;
    }
  }

  _initDb() async {
    String databasepath = await getDatabasesPath();
    String path = join(databasepath, 'accounts.db');
    print('Database path: $path');
    Database mydb = await openDatabase(path, onCreate: _onCreate,version: 1,onUpgrade: _onUpgrade); //version is used when we want to update the db tables so we change the version
    return mydb;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE items (id INTEGER PRIMARY KEY AUTOINCREMENT, singer TEXT, name TEXT, imagePath TEXT, audioPath TEXT, duration TEXT, lyrics TEXT)',
    );
    print("Created db ");
  }

  _onUpgrade(Database db, int oldversion, int newversion) async {
    await db.execute(
      'CREATE TABLE items (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)',
    );
  }



  readData(String sql) async {
    Database? mydb = await database;
    List<Map> response = await mydb!.rawQuery(sql);
    return response;
  }

  insertData(String sql) async {
    Database? mydb = await database;
    int response = await mydb!.rawInsert(sql);
    return response;
  }

  updateData(String sql) async {
    Database? mydb = await database;
    int response = await mydb!.rawUpdate(sql);
    return response;
  }

    deleteData(String sql) async {
    Database? mydb = await database;
    int response = await mydb!.rawDelete(sql);
    return response;
  }

  Future<int> insertsong(Song song) async {
    String sql = '''
      INSERT INTO items (singer, name, imagePath, audioPath, duration, lyrics)
      VALUES ("${song.singer}", "${song.name}", "${song.imagePath}", "${song.audioPath}", "${song.duration.inSeconds}", "${song.lyrics}")
    ''';
    return await insertData(sql);
  }

  Future<List<Map>> readsongs() async {
    String sql = 'SELECT * FROM items';
    return await readData(sql);
  }


  Future<Map<String, dynamic>?> readsongbyid(int id) async {
    String sql = 'SELECT * FROM items WHERE id = $id';
    List<Map> result = await readData(sql);
    return result.isNotEmpty ? result.first as Map<String, dynamic> : null;
  }

  Future<int> deletesong(int id) async {
    String sql = 'DELETE FROM items WHERE id = $id';
    return await deleteData(sql);
  }

Future<int> deletesongByNameAndSinger(String name, String singer) async {
  String sql = '''
    DELETE FROM items WHERE name = "$name" AND singer = "$singer"
  ''';
  return await deleteData(sql);
}

}