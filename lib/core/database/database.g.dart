// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ReporterFilesTable extends ReporterFiles
    with TableInfo<$ReporterFilesTable, ReporterFile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReporterFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _fileNameMeta =
      const VerificationMeta('fileName');
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
      'file_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _filePathMeta =
      const VerificationMeta('filePath');
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<String> timestamp = GeneratedColumn<String>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, fileName, filePath, timestamp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reporter_files';
  @override
  VerificationContext validateIntegrity(Insertable<ReporterFile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('file_name')) {
      context.handle(_fileNameMeta,
          fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta));
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(_filePathMeta,
          filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta));
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReporterFile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReporterFile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      fileName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_name'])!,
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}timestamp'])!,
    );
  }

  @override
  $ReporterFilesTable createAlias(String alias) {
    return $ReporterFilesTable(attachedDatabase, alias);
  }
}

class ReporterFile extends DataClass implements Insertable<ReporterFile> {
  final int id;
  final String fileName;
  final String filePath;
  final String timestamp;
  const ReporterFile(
      {required this.id,
      required this.fileName,
      required this.filePath,
      required this.timestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['file_name'] = Variable<String>(fileName);
    map['file_path'] = Variable<String>(filePath);
    map['timestamp'] = Variable<String>(timestamp);
    return map;
  }

  ReporterFilesCompanion toCompanion(bool nullToAbsent) {
    return ReporterFilesCompanion(
      id: Value(id),
      fileName: Value(fileName),
      filePath: Value(filePath),
      timestamp: Value(timestamp),
    );
  }

  factory ReporterFile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReporterFile(
      id: serializer.fromJson<int>(json['id']),
      fileName: serializer.fromJson<String>(json['fileName']),
      filePath: serializer.fromJson<String>(json['filePath']),
      timestamp: serializer.fromJson<String>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fileName': serializer.toJson<String>(fileName),
      'filePath': serializer.toJson<String>(filePath),
      'timestamp': serializer.toJson<String>(timestamp),
    };
  }

  ReporterFile copyWith(
          {int? id, String? fileName, String? filePath, String? timestamp}) =>
      ReporterFile(
        id: id ?? this.id,
        fileName: fileName ?? this.fileName,
        filePath: filePath ?? this.filePath,
        timestamp: timestamp ?? this.timestamp,
      );
  ReporterFile copyWithCompanion(ReporterFilesCompanion data) {
    return ReporterFile(
      id: data.id.present ? data.id.value : this.id,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReporterFile(')
          ..write('id: $id, ')
          ..write('fileName: $fileName, ')
          ..write('filePath: $filePath, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, fileName, filePath, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReporterFile &&
          other.id == this.id &&
          other.fileName == this.fileName &&
          other.filePath == this.filePath &&
          other.timestamp == this.timestamp);
}

class ReporterFilesCompanion extends UpdateCompanion<ReporterFile> {
  final Value<int> id;
  final Value<String> fileName;
  final Value<String> filePath;
  final Value<String> timestamp;
  const ReporterFilesCompanion({
    this.id = const Value.absent(),
    this.fileName = const Value.absent(),
    this.filePath = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  ReporterFilesCompanion.insert({
    this.id = const Value.absent(),
    required String fileName,
    required String filePath,
    required String timestamp,
  })  : fileName = Value(fileName),
        filePath = Value(filePath),
        timestamp = Value(timestamp);
  static Insertable<ReporterFile> custom({
    Expression<int>? id,
    Expression<String>? fileName,
    Expression<String>? filePath,
    Expression<String>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fileName != null) 'file_name': fileName,
      if (filePath != null) 'file_path': filePath,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  ReporterFilesCompanion copyWith(
      {Value<int>? id,
      Value<String>? fileName,
      Value<String>? filePath,
      Value<String>? timestamp}) {
    return ReporterFilesCompanion(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<String>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReporterFilesCompanion(')
          ..write('id: $id, ')
          ..write('fileName: $fileName, ')
          ..write('filePath: $filePath, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

class $RelatedUsersTable extends RelatedUsers
    with TableInfo<$RelatedUsersTable, RelatedUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RelatedUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _firstNameMeta =
      const VerificationMeta('firstName');
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
      'first_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastNameMeta =
      const VerificationMeta('lastName');
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
      'last_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _userNameMeta =
      const VerificationMeta('userName');
  @override
  late final GeneratedColumn<String> userName = GeneratedColumn<String>(
      'user_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _mobileMeta = const VerificationMeta('mobile');
  @override
  late final GeneratedColumn<String> mobile = GeneratedColumn<String>(
      'mobile', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
      'age', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
      'gender', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [firstName, lastName, userName, email, mobile, age, gender];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'related_users';
  @override
  VerificationContext validateIntegrity(Insertable<RelatedUser> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('first_name')) {
      context.handle(_firstNameMeta,
          firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta));
    }
    if (data.containsKey('last_name')) {
      context.handle(_lastNameMeta,
          lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta));
    }
    if (data.containsKey('user_name')) {
      context.handle(_userNameMeta,
          userName.isAcceptableOrUnknown(data['user_name']!, _userNameMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('mobile')) {
      context.handle(_mobileMeta,
          mobile.isAcceptableOrUnknown(data['mobile']!, _mobileMeta));
    }
    if (data.containsKey('age')) {
      context.handle(
          _ageMeta, age.isAcceptableOrUnknown(data['age']!, _ageMeta));
    }
    if (data.containsKey('gender')) {
      context.handle(_genderMeta,
          gender.isAcceptableOrUnknown(data['gender']!, _genderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  RelatedUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RelatedUser(
      firstName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}first_name']),
      lastName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_name']),
      userName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_name']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      mobile: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mobile']),
      age: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}age']),
      gender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gender']),
    );
  }

  @override
  $RelatedUsersTable createAlias(String alias) {
    return $RelatedUsersTable(attachedDatabase, alias);
  }
}

class RelatedUser extends DataClass implements Insertable<RelatedUser> {
  final String? firstName;
  final String? lastName;
  final String? userName;
  final String? email;
  final String? mobile;
  final int? age;
  final String? gender;
  const RelatedUser(
      {this.firstName,
      this.lastName,
      this.userName,
      this.email,
      this.mobile,
      this.age,
      this.gender});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || firstName != null) {
      map['first_name'] = Variable<String>(firstName);
    }
    if (!nullToAbsent || lastName != null) {
      map['last_name'] = Variable<String>(lastName);
    }
    if (!nullToAbsent || userName != null) {
      map['user_name'] = Variable<String>(userName);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || mobile != null) {
      map['mobile'] = Variable<String>(mobile);
    }
    if (!nullToAbsent || age != null) {
      map['age'] = Variable<int>(age);
    }
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    return map;
  }

  RelatedUsersCompanion toCompanion(bool nullToAbsent) {
    return RelatedUsersCompanion(
      firstName: firstName == null && nullToAbsent
          ? const Value.absent()
          : Value(firstName),
      lastName: lastName == null && nullToAbsent
          ? const Value.absent()
          : Value(lastName),
      userName: userName == null && nullToAbsent
          ? const Value.absent()
          : Value(userName),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      mobile:
          mobile == null && nullToAbsent ? const Value.absent() : Value(mobile),
      age: age == null && nullToAbsent ? const Value.absent() : Value(age),
      gender:
          gender == null && nullToAbsent ? const Value.absent() : Value(gender),
    );
  }

  factory RelatedUser.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RelatedUser(
      firstName: serializer.fromJson<String?>(json['firstName']),
      lastName: serializer.fromJson<String?>(json['lastName']),
      userName: serializer.fromJson<String?>(json['userName']),
      email: serializer.fromJson<String?>(json['email']),
      mobile: serializer.fromJson<String?>(json['mobile']),
      age: serializer.fromJson<int?>(json['age']),
      gender: serializer.fromJson<String?>(json['gender']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'firstName': serializer.toJson<String?>(firstName),
      'lastName': serializer.toJson<String?>(lastName),
      'userName': serializer.toJson<String?>(userName),
      'email': serializer.toJson<String?>(email),
      'mobile': serializer.toJson<String?>(mobile),
      'age': serializer.toJson<int?>(age),
      'gender': serializer.toJson<String?>(gender),
    };
  }

  RelatedUser copyWith(
          {Value<String?> firstName = const Value.absent(),
          Value<String?> lastName = const Value.absent(),
          Value<String?> userName = const Value.absent(),
          Value<String?> email = const Value.absent(),
          Value<String?> mobile = const Value.absent(),
          Value<int?> age = const Value.absent(),
          Value<String?> gender = const Value.absent()}) =>
      RelatedUser(
        firstName: firstName.present ? firstName.value : this.firstName,
        lastName: lastName.present ? lastName.value : this.lastName,
        userName: userName.present ? userName.value : this.userName,
        email: email.present ? email.value : this.email,
        mobile: mobile.present ? mobile.value : this.mobile,
        age: age.present ? age.value : this.age,
        gender: gender.present ? gender.value : this.gender,
      );
  RelatedUser copyWithCompanion(RelatedUsersCompanion data) {
    return RelatedUser(
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      userName: data.userName.present ? data.userName.value : this.userName,
      email: data.email.present ? data.email.value : this.email,
      mobile: data.mobile.present ? data.mobile.value : this.mobile,
      age: data.age.present ? data.age.value : this.age,
      gender: data.gender.present ? data.gender.value : this.gender,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RelatedUser(')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('userName: $userName, ')
          ..write('email: $email, ')
          ..write('mobile: $mobile, ')
          ..write('age: $age, ')
          ..write('gender: $gender')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(firstName, lastName, userName, email, mobile, age, gender);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RelatedUser &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.userName == this.userName &&
          other.email == this.email &&
          other.mobile == this.mobile &&
          other.age == this.age &&
          other.gender == this.gender);
}

class RelatedUsersCompanion extends UpdateCompanion<RelatedUser> {
  final Value<String?> firstName;
  final Value<String?> lastName;
  final Value<String?> userName;
  final Value<String?> email;
  final Value<String?> mobile;
  final Value<int?> age;
  final Value<String?> gender;
  final Value<int> rowid;
  const RelatedUsersCompanion({
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.userName = const Value.absent(),
    this.email = const Value.absent(),
    this.mobile = const Value.absent(),
    this.age = const Value.absent(),
    this.gender = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RelatedUsersCompanion.insert({
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.userName = const Value.absent(),
    this.email = const Value.absent(),
    this.mobile = const Value.absent(),
    this.age = const Value.absent(),
    this.gender = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<RelatedUser> custom({
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? userName,
    Expression<String>? email,
    Expression<String>? mobile,
    Expression<int>? age,
    Expression<String>? gender,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (userName != null) 'user_name': userName,
      if (email != null) 'email': email,
      if (mobile != null) 'mobile': mobile,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RelatedUsersCompanion copyWith(
      {Value<String?>? firstName,
      Value<String?>? lastName,
      Value<String?>? userName,
      Value<String?>? email,
      Value<String?>? mobile,
      Value<int?>? age,
      Value<String?>? gender,
      Value<int>? rowid}) {
    return RelatedUsersCompanion(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (userName.present) {
      map['user_name'] = Variable<String>(userName.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (mobile.present) {
      map['mobile'] = Variable<String>(mobile.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RelatedUsersCompanion(')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('userName: $userName, ')
          ..write('email: $email, ')
          ..write('mobile: $mobile, ')
          ..write('age: $age, ')
          ..write('gender: $gender, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ReporterFilesTable reporterFiles = $ReporterFilesTable(this);
  late final $RelatedUsersTable relatedUsers = $RelatedUsersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [reporterFiles, relatedUsers];
}

typedef $$ReporterFilesTableCreateCompanionBuilder = ReporterFilesCompanion
    Function({
  Value<int> id,
  required String fileName,
  required String filePath,
  required String timestamp,
});
typedef $$ReporterFilesTableUpdateCompanionBuilder = ReporterFilesCompanion
    Function({
  Value<int> id,
  Value<String> fileName,
  Value<String> filePath,
  Value<String> timestamp,
});

class $$ReporterFilesTableFilterComposer
    extends Composer<_$AppDatabase, $ReporterFilesTable> {
  $$ReporterFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fileName => $composableBuilder(
      column: $table.fileName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));
}

class $$ReporterFilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReporterFilesTable> {
  $$ReporterFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fileName => $composableBuilder(
      column: $table.fileName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));
}

class $$ReporterFilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReporterFilesTable> {
  $$ReporterFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$ReporterFilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReporterFilesTable,
    ReporterFile,
    $$ReporterFilesTableFilterComposer,
    $$ReporterFilesTableOrderingComposer,
    $$ReporterFilesTableAnnotationComposer,
    $$ReporterFilesTableCreateCompanionBuilder,
    $$ReporterFilesTableUpdateCompanionBuilder,
    (
      ReporterFile,
      BaseReferences<_$AppDatabase, $ReporterFilesTable, ReporterFile>
    ),
    ReporterFile,
    PrefetchHooks Function()> {
  $$ReporterFilesTableTableManager(_$AppDatabase db, $ReporterFilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReporterFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReporterFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReporterFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> fileName = const Value.absent(),
            Value<String> filePath = const Value.absent(),
            Value<String> timestamp = const Value.absent(),
          }) =>
              ReporterFilesCompanion(
            id: id,
            fileName: fileName,
            filePath: filePath,
            timestamp: timestamp,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String fileName,
            required String filePath,
            required String timestamp,
          }) =>
              ReporterFilesCompanion.insert(
            id: id,
            fileName: fileName,
            filePath: filePath,
            timestamp: timestamp,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReporterFilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReporterFilesTable,
    ReporterFile,
    $$ReporterFilesTableFilterComposer,
    $$ReporterFilesTableOrderingComposer,
    $$ReporterFilesTableAnnotationComposer,
    $$ReporterFilesTableCreateCompanionBuilder,
    $$ReporterFilesTableUpdateCompanionBuilder,
    (
      ReporterFile,
      BaseReferences<_$AppDatabase, $ReporterFilesTable, ReporterFile>
    ),
    ReporterFile,
    PrefetchHooks Function()>;
typedef $$RelatedUsersTableCreateCompanionBuilder = RelatedUsersCompanion
    Function({
  Value<String?> firstName,
  Value<String?> lastName,
  Value<String?> userName,
  Value<String?> email,
  Value<String?> mobile,
  Value<int?> age,
  Value<String?> gender,
  Value<int> rowid,
});
typedef $$RelatedUsersTableUpdateCompanionBuilder = RelatedUsersCompanion
    Function({
  Value<String?> firstName,
  Value<String?> lastName,
  Value<String?> userName,
  Value<String?> email,
  Value<String?> mobile,
  Value<int?> age,
  Value<String?> gender,
  Value<int> rowid,
});

class $$RelatedUsersTableFilterComposer
    extends Composer<_$AppDatabase, $RelatedUsersTable> {
  $$RelatedUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userName => $composableBuilder(
      column: $table.userName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mobile => $composableBuilder(
      column: $table.mobile, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnFilters(column));
}

class $$RelatedUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $RelatedUsersTable> {
  $$RelatedUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userName => $composableBuilder(
      column: $table.userName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mobile => $composableBuilder(
      column: $table.mobile, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnOrderings(column));
}

class $$RelatedUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RelatedUsersTable> {
  $$RelatedUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get userName =>
      $composableBuilder(column: $table.userName, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get mobile =>
      $composableBuilder(column: $table.mobile, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);
}

class $$RelatedUsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RelatedUsersTable,
    RelatedUser,
    $$RelatedUsersTableFilterComposer,
    $$RelatedUsersTableOrderingComposer,
    $$RelatedUsersTableAnnotationComposer,
    $$RelatedUsersTableCreateCompanionBuilder,
    $$RelatedUsersTableUpdateCompanionBuilder,
    (
      RelatedUser,
      BaseReferences<_$AppDatabase, $RelatedUsersTable, RelatedUser>
    ),
    RelatedUser,
    PrefetchHooks Function()> {
  $$RelatedUsersTableTableManager(_$AppDatabase db, $RelatedUsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RelatedUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RelatedUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RelatedUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String?> firstName = const Value.absent(),
            Value<String?> lastName = const Value.absent(),
            Value<String?> userName = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> mobile = const Value.absent(),
            Value<int?> age = const Value.absent(),
            Value<String?> gender = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RelatedUsersCompanion(
            firstName: firstName,
            lastName: lastName,
            userName: userName,
            email: email,
            mobile: mobile,
            age: age,
            gender: gender,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String?> firstName = const Value.absent(),
            Value<String?> lastName = const Value.absent(),
            Value<String?> userName = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> mobile = const Value.absent(),
            Value<int?> age = const Value.absent(),
            Value<String?> gender = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RelatedUsersCompanion.insert(
            firstName: firstName,
            lastName: lastName,
            userName: userName,
            email: email,
            mobile: mobile,
            age: age,
            gender: gender,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RelatedUsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RelatedUsersTable,
    RelatedUser,
    $$RelatedUsersTableFilterComposer,
    $$RelatedUsersTableOrderingComposer,
    $$RelatedUsersTableAnnotationComposer,
    $$RelatedUsersTableCreateCompanionBuilder,
    $$RelatedUsersTableUpdateCompanionBuilder,
    (
      RelatedUser,
      BaseReferences<_$AppDatabase, $RelatedUsersTable, RelatedUser>
    ),
    RelatedUser,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ReporterFilesTableTableManager get reporterFiles =>
      $$ReporterFilesTableTableManager(_db, _db.reporterFiles);
  $$RelatedUsersTableTableManager get relatedUsers =>
      $$RelatedUsersTableTableManager(_db, _db.relatedUsers);
}
