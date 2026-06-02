import 'package:drift/drift.dart';

class ReporterFiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get fileName => text()();
  TextColumn get filePath => text()();
  TextColumn get timestamp => text()();
}

class RelatedUsers extends Table {
  TextColumn get firstName => text().nullable()();
  TextColumn get lastName => text().nullable()();
  TextColumn get userName => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get mobile => text().nullable()();
  IntColumn get age => integer().nullable()();
  TextColumn get gender => text().nullable()();
}
