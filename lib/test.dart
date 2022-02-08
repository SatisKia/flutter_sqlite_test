import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import 'main.dart';

class MyText extends Container {
  MyText( MyHomePageState state, String text, {Key? key} ) : super(key: key,
      width: state.contentWidth,
      alignment: Alignment.topLeft,
      child: Text( text )
  );
}
class MyTextColor extends Container {
  MyTextColor( MyHomePageState state, String text, {Key? key} ) : super(key: key,
      width: state.contentWidth,
      alignment: Alignment.topLeft,
      child: Text(
          text,
          style: const TextStyle(
              color: Color( 0xFF0000FF )
          )
      )
  );
}

Future debugPrintTable( MyHomePageState state, Database database ) async {
  // データの取得
  List<Map> list = await database.rawQuery(
      'SELECT * FROM Hoge'
  );
  if( list.isNotEmpty ) {
    state.addConsole( MyText(state, "--------------------") );
    for (var element in list) {
      element.forEach((key, value) {
        state.addConsole( MyText(state, "$key: $value") );
      });
      state.addConsole( MyText(state, "--------------------") );
    }
  }
}

Future test( MyHomePageState state, bool clean, bool raw, int version ) async {
  // データベースファイルのパスを取得する
  String databasesPath = await getDatabasesPath();
  state.addConsole( MyText(state, databasesPath) );
  String dbFile = path.join(databasesPath, 'hoge.db');
  state.addConsole( MyText(state, dbFile) );

  if( clean ) {
    // データベースを削除する
    await deleteDatabase(dbFile);
  }

  // データベースを開く
  state.addConsole( MyTextColor(state, 'OPEN') );
  Database? database;
  switch( version ){
    case 1:
      database = await openDatabase(dbFile, version: 1,
          onCreate: (Database db, int version) async {
            String query = 'CREATE TABLE Hoge ('
                'id INTEGER PRIMARY KEY,'
                'name TEXT,'
                'age INTEGER,'
                'point REAL'
                ')';
            state.addConsole( MyTextColor(state, query) );
            await db.execute(query);
          }
      );
      break;
    case 2:
      database = await openDatabase(dbFile, version: 2,
          onCreate: (Database db, int version) async {
            String query = 'CREATE TABLE Hoge ('
                'id INTEGER PRIMARY KEY,'
                'name TEXT,'
                'age INTEGER,'
                'point REAL,'
                'create_at TIMESTAMP,' // バージョン2で追加
                'update_at TIMESTAMP' // バージョン2で追加
                ')';
            state.addConsole( MyTextColor(state, query) );
            await db.execute(query);
          },
          onUpgrade: (Database db, int oldVersion, int newVersion) async {
            const scripts = {
              '2': [
                'ALTER TABLE Hoge ADD COLUMN create_at TIMESTAMP',
                'ALTER TABLE Hoge ADD COLUMN update_at TIMESTAMP'
              ],
            };
            for (var i = oldVersion + 1; i <= newVersion; i++) {
              var queries = scripts[i.toString()];
              for (String query in queries!) {
                state.addConsole( MyTextColor(state, query) );
                await db.execute(query);
              }
            }
          }
      );
      break;
    case 3:
      database = await openDatabase(dbFile, version: 3,
          onCreate: (Database db, int version) async {
            String query = 'CREATE TABLE Hoge ('
                'id INTEGER PRIMARY KEY,'
                'name TEXT,'
                'age INTEGER,'
                'point REAL,'
                'create_at TIMESTAMP,'
                'update_at TIMESTAMP,'
                'profile TEXT' // バージョン3で追加
                ')';
            state.addConsole( MyTextColor(state, query) );
            await db.execute(query);
          },
          onUpgrade: (Database db, int oldVersion, int newVersion) async {
            const scripts = {
              '2': [
                'ALTER TABLE Hoge ADD COLUMN create_at TIMESTAMP',
                'ALTER TABLE Hoge ADD COLUMN update_at TIMESTAMP'
              ],
              '3': [
                'ALTER TABLE Hoge ADD COLUMN profile TEXT'
              ],
            };
            for (var i = oldVersion + 1; i <= newVersion; i++) {
              var queries = scripts[i.toString()];
              for (String query in queries!) {
                state.addConsole( MyTextColor(state, query) );
                await db.execute(query);
              }
            }
          }
      );
      break;
  }

  // バージョンの確認
  int version2 = await database!.getVersion();
  state.addConsole( MyText(state, 'version: $version2') );

  // レコード数の取得
  state.addConsole( MyTextColor(state, 'COUNT') );
  int? count = Sqflite.firstIntValue(
      await database.rawQuery(
          'SELECT COUNT(*) FROM Hoge'
      )
  );
  state.addConsole( MyText(state, "count: $count") );

  // レコードの挿入
  state.addConsole( MyTextColor(state, 'INSERT') );
  await database.transaction((txn) async {
    if( count == 0 ) {
      int id1;
      if( raw ) {
        id1 = await txn.rawInsert(
            'INSERT INTO Hoge(name, age, point) VALUES("hoge", 21, 3.5)'
        );
      } else {
        Map<String, Object?> values1 = {
          'name': 'hoge',
          'age': 21,
          'point': 3.5
        };
        id1 = await txn.insert('Hoge', values1);
      }
      state.addConsole( MyText(state, "insert id: $id1") );
    }
    int id2;
    if( version == 1 ){
      if( raw ) {
        id2 = await txn.rawInsert(
            'INSERT INTO Hoge(name, age, point) VALUES(?, ?, ?)',
            ['fuga', 19, 4.1]
        );
      } else {
        Map<String, Object?> values2 = {
          'name': 'fuga',
          'age': 19,
          'point': 4.1
        };
        id2 = await txn.insert('Hoge', values2);
      }
    } else if( version == 2 ){
      String now = DateTime.now().toString();
      if( raw ) {
        id2 = await txn.rawInsert(
            'INSERT INTO Hoge(name, age, point, create_at, update_at) VALUES(?, ?, ?, ?, ?)',
            ['fuga', 19, 4.1, now, now]
        );
      } else {
        Map<String, Object?> values2 = {
          'name': 'fuga',
          'age': 19,
          'point': 4.1,
          'create_at': now,
          'update_at': now
        };
        id2 = await txn.insert('Hoge', values2);
      }
    } else {
      String now = DateTime.now().toString();
      if( raw ) {
        id2 = await txn.rawInsert(
            'INSERT INTO Hoge(name, age, point, create_at, update_at, profile) VALUES(?, ?, ?, ?, ?, ?)',
            ['fuga', 19, 4.1, now, now, 'abcde']
        );
      } else {
        Map<String, Object?> values2 = {
          'name': 'fuga',
          'age': 19,
          'point': 4.1,
          'create_at': now,
          'update_at': now,
          'profile': 'abcde'
        };
        id2 = await txn.insert('Hoge', values2);
      }
    }
    state.addConsole( MyText(state, "insert id: $id2") );
  });
  await debugPrintTable( state, database );

  // データの更新
  state.addConsole( MyTextColor(state, 'UPDATE') );
  int count2;
  if( version == 1 ){
    if( raw ) {
      count2 = await database.rawUpdate(
          'UPDATE Hoge SET age = ?, point = ? WHERE name = ?',
          [20, 3.9, 'fuga']
      );
    } else {
      Map<String, Object?> values = {
        'age': 20,
        'point': 3.9
      };
      count2 = await database.update('Hoge', values, where: 'name = ?', whereArgs: ['fuga']);
    }
  } else {
    if( raw ) {
      count2 = await database.rawUpdate(
          'UPDATE Hoge SET age = ?, point = ?, update_at = ? WHERE name = ?',
          [20, 3.9, DateTime.now().toString(), 'fuga']
      );
    } else {
      Map<String, Object?> values = {
        'age': 20,
        'point': 3.9,
        'update_at': DateTime.now().toString()
      };
      count2 = await database.update('Hoge', values, where: 'name = ?', whereArgs: ['fuga']);
    }
  }
  state.addConsole( MyText(state, "count: $count2") );
  await debugPrintTable( state, database );

  // レコードの削除
  state.addConsole( MyTextColor(state, 'DELETE') );
  int count3;
  if( raw ) {
    count3 = await database.rawDelete(
        'DELETE FROM Hoge WHERE name = ?',
        ['fuga']
    );
  } else {
    count3 = await database.delete('Hoge', where: 'name = ?', whereArgs: ['fuga']);
  }
  state.addConsole( MyText(state, "count: $count3") );
  await debugPrintTable( state, database );

  // データベースを閉じる
  state.addConsole( MyTextColor(state, 'CLOSE') );
  await database.close();
}

Future test2( MyHomePageState state, bool clean ) async {
  // データベースファイルのパスを取得する
  String databasesPath = await getDatabasesPath();
  state.addConsole( MyText(state, databasesPath) );
  String dbFile = path.join(databasesPath, 'test.db');
  state.addConsole( MyText(state, dbFile) );

  if( clean ) {
    // データベースを削除する
    await deleteDatabase(dbFile);
  }

  // データベースを開く
  bool exists = await databaseExists(dbFile);
  if (!exists) {
    ByteData data = await rootBundle.load(path.join('assets', 'test.db'));
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(dbFile).writeAsBytes(bytes, flush: true);
    state.addConsole( MyTextColor(state, 'CREATE') );
  } else {
    state.addConsole( MyTextColor(state, 'OPEN') );
  }
  Database database = await openDatabase(dbFile);

  // バージョンの確認
  int version = await database.getVersion();
  state.addConsole( MyText(state, 'version: $version') );

  // データの取得
  await debugPrintTable( state, database );

  // データベースを閉じる
  state.addConsole( MyTextColor(state, 'CLOSE') );
  await database.close();
}
