import 'package:pokedexapp/helpers/pokeapi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class BaseDatos {
  static const _dbName = 'pokedex.db';
  static const _dbVersion = 1;

  BaseDatos._privateConstructor();
  static final BaseDatos instance = BaseDatos._privateConstructor();

  static Database? _db;
  static bool _initialized = false;

  Future<Database> get database async {
    if (_db != null && _initialized) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  // Inicializa la base de datos y las tablas
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    Database db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onOpen: (db) async {
        await _createTables(db);
      },
    );

    // Solo inserta datos si la tabla está vacía
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM pokemones'),
    );
    if (count == 0) {
      late final List lista;
      try {
        lista = await PokeAPI().fetchPokemonList();
      } catch (e) {
        throw "Error al obtener la lista de Pokémones: $e";
      }
      await _insertPokemones(db, lista);
    }

    _initialized = true;
    return db;
  }

  // Crea las tablas si no existen
  Future<void> _createTables(Database db) async {
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
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS equipos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL UNIQUE,
        creador TEXT NOT NULL,
        descripcion TEXT NOT NULL
      );
    ''');
  }

  // Inserta los pokemones en la tabla
  Future<void> _insertPokemones(Database db, List lista) async {
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
}
