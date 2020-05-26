import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseProvider {
  
  static final _databaseName = "saleschat.db";
  static final _databaseVersion = 1;

  // make this a singleton class
  DatabaseProvider._privateConstructor();
  static final DatabaseProvider instance = DatabaseProvider._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }
  
  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE CONTACTS (
        USERID TEXT PRIMARY KEY,
        PHOTO TEXT NOT NULL,
        STATE TEXT NOT NULL,
        USERNAME TEXT NOT NULL,
        PHONE TEXT NOT NULL,
        NAME TEXT NOT NULL,
        ME INTEGER NOT NULL
      )
      ''');
    await db.execute('''
      CREATE TABLE MESSAGES (
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        UUID TEXT,
        MESSAGERID TEXT NOT NULL,
        MESSAGE TEXT NOT NULL,
        DATE TEXT NOT NULL,
        ME INTEGER NOT NULL
      )
      ''');
    await db.execute('''
      CREATE TABLE GROUPS (
        UUID TEXT PRIMARY KEY,
        PHOTO TEXT NOT NULL,
        TITLE TEXT NOT NULL,
        DESCRIPTION TEXT NOT NULL,
        CREATOR TEXT NOT NULL
      )
      ''');
    await db.execute('''
      CREATE TABLE MEMBERSGROUPS (
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        UUID TEXT NOT NULL,
        USERID TEXT NOT NULL,
        foreign key(UUID) references groups(UUID)
      )
      ''');
      await db.execute('''
      CREATE TABLE CHATS (
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        USERID TEXT NOT NULL
      )
      ''');
  }
  
  // Provider methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row, String table) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  // All of the rows are returned as a list of maps, where each map is 
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount(String table) async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  // We are assuming here that the id column in the map is set. The other 
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row, String table) async {
    Database db = await instance.database;
    int id = row['ID'];
    return await db.update(table, row, where: 'ID = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is 
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id, table) async {
    Database db = await instance.database;
    return await db.delete(table, where: 'ID = ?', whereArgs: [id]);
  }

  Future<int> deleteMany(String table) async {
    Database db = await instance.database;
    return await db.delete(table);
  }

  Future<List<Map<String, dynamic>>> queryJoin(String table,String table2, String column, String column2) async {
    Database db = await instance.database;
    var result = await db.rawQuery('SELECT * FROM $table INNER JOIN $table2 ON $table.$column = $table2.$column2;');
    print('HOLA');
    return result;
  }

  Future<List<Map<String, dynamic>>> queryWhereOrderDesc(String table, String column, String value, String columnOrder) async {
    Database db = await instance.database;
    return await db.rawQuery('SELECT * FROM $table WHERE $column = \'$value\' ORDER BY $columnOrder DESC;');
  }

  Future<int> queryWhereCount(String table, String column, String value) async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table WHERE $column = \'$value\';'));
  }

  Future<List<Map<String, dynamic>>> queryWhere(String table, String column, String value) async {
    Database db = await instance.database;
    return await db.rawQuery('SELECT * FROM $table WHERE $column = \'$value\';');
  }
  Future<int> updateWhere(Map<String, dynamic> row, String table, String column, String value) async {
    Database db = await instance.database;
    return await db.update(table, row, where: '$column = \'$value\'');
  }
}