/// Este archivo define el módulo de acceso a la base de datos local SQLite.
/// Proporciona métodos para inicializar la base, realizar consultas, inserciones y actualizaciones.

import 'package:pokedexapp/helpers/pokeapi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Singleton (instancia única) para manejar la base de datos.
///
/// De esta manera, no es necesario inicializar la base de datos múltiples veces cada vez que se
/// necesite realizar una consulta.
///
/// Propósito: Agilizar la consulta de equipos y Pokémones, evitando congestionar la PokéAPI
/// sobresaturándola de múltiples solicitudes a la vez y en poco tiempo.
class BaseDatos {
  static const _dbName = 'pokedex.db'; // Nombre de la base de datos.
  static const _dbVersion = 1; // Versión de la base de datos.

  BaseDatos._privateConstructor();
  static final BaseDatos instance = BaseDatos._privateConstructor();

  static Database? _db;
  static bool _initialized = false;

  /// Obtiene la instancia de la base de datos.
  Future<Database> get database async {
    if (_db != null && _initialized) return _db!;
    _db = await _initDB();
    return _db!;
  }

  /// Inicializa la base de datos.
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    Database db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await _crearTablas(db);
      },
      onOpen: (db) async {
        await _crearTablas(db);
      },
    );

    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM pokemones'),
    );
    /* Si la tabla de Pokémones está vacía, se obtienen los datos de la API.

    Una vez insertados los Pokémones en la base de datos, no es necesario volverlos a
    consultar a través de la PokéAPI.
    */
    if (count == 0) {
      late final List lista;
      try {
        lista = await PokeAPI().fetchPokemonList();
      } catch (e) {
        throw "Error al obtener la lista de Pokémones: $e";
      }
      await _insertarPokemones(db, lista);
    }

    _initialized = true;
    return db;
  }

  /// Crea las tablas en la base de datos.
  Future<void> _crearTablas(Database db) async {
    // Crea la tabla de Pokémones.
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

    // Crea la tabla de equipos.
    await db.execute('''
      CREATE TABLE IF NOT EXISTS equipos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL UNIQUE,
        creador TEXT NOT NULL,
        descripcion TEXT NOT NULL
      );
    ''');
  }

  /// Inserta los Pokémones en la tabla.
  ///
  /// [lista] es la lista de Pokémones a insertar obtenida de la PokéAPI.
  Future<void> _insertarPokemones(Database db, List lista) async {
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

  /// Inserta un nuevo registro en la tabla especificada.
  ///
  /// [tabla] es el nombre de la tabla donde se insertará el registro.
  /// [valores] son los valores a insertar en forma de mapa.
  Future<int> insertar(String tabla, Map<String, dynamic> valores) async {
    final db = await database;
    return await db.insert(tabla, valores);
  }

  /// Busca un registro en la tabla especificada.
  ///
  /// [tabla] es el nombre de la tabla donde se realizará la búsqueda.
  /// [id] es el identificador del registro a buscar.
  Future<List<Map<String, dynamic>>> buscar(String tabla, int id) async {
    final db = await database;
    return await db.query(tabla, where: 'id = ?', whereArgs: [id]);
  }

  /// Busca todos los registros en la tabla especificada.
  ///
  /// [tabla] es el nombre de la tabla donde se realizará la búsqueda.
  Future<List<Map<String, dynamic>>> buscarTodo(String tabla) async {
    final db = await database;
    return await db.query(tabla);
  }

  /// Actualiza un registro en la tabla especificada.
  ///
  /// [tabla] es el nombre de la tabla donde se realizará la actualización.
  /// [valores] son los nuevos valores a actualizar en forma de mapa.
  /// [where] es la cláusula WHERE para identificar qué registros actualizar.
  /// [whereArgs] son los argumentos para la cláusula WHERE.
  Future<int> actualizar(
    String tabla,
    Map<String, dynamic> valores,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.update(tabla, valores, where: where, whereArgs: whereArgs);
  }
}
