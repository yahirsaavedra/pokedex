import 'package:flutter/material.dart';
import 'package:pokedexapp/helpers/pokeapi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class BaseDatos {
  // Nombre y versión de la BD
  static const _dbName = 'pokedex.db';
  static const _dbVersion = 1;

  // Singleton (instancia unica)
  BaseDatos._privateConstructor();
  static final BaseDatos instance = BaseDatos._privateConstructor();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  // Inicializa la base de datos
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    late final List lista;
    try {
      lista = await PokeAPI().fetchPokemonList();
    } catch (e) {
      throw "Error al obtener la lista de Pokémones: $e";
    }

    Database db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) => _onCreate(db, version, lista),
      onOpen: (db) => _onCreate(db, _dbVersion, lista),
    );

    return db;
  }

  // Crear tablas
  Future<void> _onCreate(Database db, int version, List lista) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pokemones (
        id INTEGER PRIMARY KEY,
        nombre TEXT NOT NULL UNIQUE,
        tipo VARCHAR(50),
        altura DECIMAL(10, 2),
        peso DECIMAL(10, 2),
        habilidad VARCHAR(100),
        imagen VARCHAR(2048),
        descripcion TEXT,
        equipo INTEGER,
        FOREIGN KEY (equipo) REFERENCES equipos(id)
      );

      CREATE TABLE IF NOT EXISTS equipos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL UNIQUE,
        creador TEXT NOT NULL,
        descripcion TEXT NOT NULL
      );
    ''');

    debugPrint(lista.toString());

    for (var i = 0; i < lista.length; i++) {
      await db.execute('''
    INSERT OR IGNORE INTO pokemones VALUES (
      ${lista[i]["id"]},
      "${lista[i]["name"]}",
      "${lista[i]["type"]}",
      ${lista[i]["height"]},
      ${lista[i]["weight"]},
      "${lista[i]["ability"]}",
      "${lista[i]["sprites"]["front_default"]}",
      "${lista[i]["description"]}",
      NULL
    );
  ''');

      debugPrint("Pokemon insertado: ${lista[i]["name"]} - $i");
    }
  }

  // Métodos genéricos CRUD
  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await database;
    return await db.insert(table, values);
  }

  Future<List<Map<String, dynamic>>> query(String table, int id) async {
    final db = await database;
    return await db.query(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<int> update(
    String table,
    Map<String, dynamic> values,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }
}
