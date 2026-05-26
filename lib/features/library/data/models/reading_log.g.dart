// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_log.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetReadingLogCollection on Isar {
  IsarCollection<ReadingLog> get readingLogs => this.collection();
}

const ReadingLogSchema = CollectionSchema(
  name: r'ReadingLog',
  id: 7493231817925098844,
  properties: {
    r'chaptersRead': PropertySchema(
      id: 0,
      name: r'chaptersRead',
      type: IsarType.long,
    ),
    r'date': PropertySchema(
      id: 1,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'exactTimestamp': PropertySchema(
      id: 2,
      name: r'exactTimestamp',
      type: IsarType.dateTime,
    ),
    r'isImported': PropertySchema(
      id: 3,
      name: r'isImported',
      type: IsarType.bool,
    ),
    r'isPastReading': PropertySchema(
      id: 4,
      name: r'isPastReading',
      type: IsarType.bool,
    ),
    r'mangaDexId': PropertySchema(
      id: 5,
      name: r'mangaDexId',
      type: IsarType.string,
    ),
    r'sessionDurationMinutes': PropertySchema(
      id: 6,
      name: r'sessionDurationMinutes',
      type: IsarType.long,
    ),
    r'sessionId': PropertySchema(
      id: 7,
      name: r'sessionId',
      type: IsarType.long,
    )
  },
  estimateSize: _readingLogEstimateSize,
  serialize: _readingLogSerialize,
  deserialize: _readingLogDeserialize,
  deserializeProp: _readingLogDeserializeProp,
  idName: r'id',
  indexes: {
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'date',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'mangaDexId': IndexSchema(
      id: -2561072137442709649,
      name: r'mangaDexId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'mangaDexId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _readingLogGetId,
  getLinks: _readingLogGetLinks,
  attach: _readingLogAttach,
  version: '3.1.0+1',
);

int _readingLogEstimateSize(
  ReadingLog object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.mangaDexId.length * 3;
  return bytesCount;
}

void _readingLogSerialize(
  ReadingLog object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.chaptersRead);
  writer.writeDateTime(offsets[1], object.date);
  writer.writeDateTime(offsets[2], object.exactTimestamp);
  writer.writeBool(offsets[3], object.isImported);
  writer.writeBool(offsets[4], object.isPastReading);
  writer.writeString(offsets[5], object.mangaDexId);
  writer.writeLong(offsets[6], object.sessionDurationMinutes);
  writer.writeLong(offsets[7], object.sessionId);
}

ReadingLog _readingLogDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ReadingLog();
  object.chaptersRead = reader.readLong(offsets[0]);
  object.date = reader.readDateTime(offsets[1]);
  object.exactTimestamp = reader.readDateTimeOrNull(offsets[2]);
  object.id = id;
  object.isImported = reader.readBool(offsets[3]);
  object.isPastReading = reader.readBool(offsets[4]);
  object.mangaDexId = reader.readString(offsets[5]);
  object.sessionDurationMinutes = reader.readLong(offsets[6]);
  object.sessionId = reader.readLongOrNull(offsets[7]);
  return object;
}

P _readingLogDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _readingLogGetId(ReadingLog object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _readingLogGetLinks(ReadingLog object) {
  return [];
}

void _readingLogAttach(IsarCollection<dynamic> col, Id id, ReadingLog object) {
  object.id = id;
}

extension ReadingLogQueryWhereSort
    on QueryBuilder<ReadingLog, ReadingLog, QWhere> {
  QueryBuilder<ReadingLog, ReadingLog, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterWhere> anyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'date'),
      );
    });
  }
}

extension ReadingLogQueryWhere
    on QueryBuilder<ReadingLog, ReadingLog, QWhereClause> {
  QueryBuilder<ReadingLog, ReadingLog, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterWhereClause> dateEqualTo(
      DateTime date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterWhereClause> dateNotEqualTo(
      DateTime date) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterWhereClause> dateGreaterThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [date],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterWhereClause> dateLessThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [],
        upper: [date],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterWhereClause> dateBetween(
    DateTime lowerDate,
    DateTime upperDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [lowerDate],
        includeLower: includeLower,
        upper: [upperDate],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterWhereClause> mangaDexIdEqualTo(
      String mangaDexId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'mangaDexId',
        value: [mangaDexId],
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterWhereClause> mangaDexIdNotEqualTo(
      String mangaDexId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'mangaDexId',
              lower: [],
              upper: [mangaDexId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'mangaDexId',
              lower: [mangaDexId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'mangaDexId',
              lower: [mangaDexId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'mangaDexId',
              lower: [],
              upper: [mangaDexId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ReadingLogQueryFilter
    on QueryBuilder<ReadingLog, ReadingLog, QFilterCondition> {
  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition>
      chaptersReadEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chaptersRead',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition>
      chaptersReadGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chaptersRead',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition>
      chaptersReadLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chaptersRead',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition>
      chaptersReadBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chaptersRead',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition> dateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition> dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition> dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition>
      exactTimestampIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'exactTimestamp',
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition>
      exactTimestampIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'exactTimestamp',
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition>
      exactTimestampEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'exactTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition>
      exactTimestampGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'exactTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition>
      exactTimestampLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'exactTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition>
      exactTimestampBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'exactTimestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition> isImportedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isImported',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition>
      isPastReadingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPastReading',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition> mangaDexIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mangaDexId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition>
      mangaDexIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mangaDexId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition>
      mangaDexIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mangaDexId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition> mangaDexIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mangaDexId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition>
      mangaDexIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mangaDexId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition>
      mangaDexIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mangaDexId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition>
      mangaDexIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mangaDexId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition> mangaDexIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mangaDexId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition>
      mangaDexIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mangaDexId',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition>
      mangaDexIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mangaDexId',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition>
      sessionDurationMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionDurationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition>
      sessionDurationMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sessionDurationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition>
      sessionDurationMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sessionDurationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition>
      sessionDurationMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sessionDurationMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition>
      sessionIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sessionId',
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition>
      sessionIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sessionId',
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition> sessionIdEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionId',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition>
      sessionIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sessionId',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition> sessionIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sessionId',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterFilterCondition> sessionIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sessionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ReadingLogQueryObject
    on QueryBuilder<ReadingLog, ReadingLog, QFilterCondition> {}

extension ReadingLogQueryLinks
    on QueryBuilder<ReadingLog, ReadingLog, QFilterCondition> {}

extension ReadingLogQuerySortBy
    on QueryBuilder<ReadingLog, ReadingLog, QSortBy> {
  QueryBuilder<ReadingLog, ReadingLog, QAfterSortBy> sortByChaptersRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chaptersRead', Sort.asc);
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterSortBy> sortByChaptersReadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chaptersRead', Sort.desc);
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterSortBy> sortByExactTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exactTimestamp', Sort.asc);
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterSortBy>
      sortByExactTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exactTimestamp', Sort.desc);
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterSortBy> sortByIsImported() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isImported', Sort.asc);
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterSortBy> sortByIsImportedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isImported', Sort.desc);
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterSortBy> sortByIsPastReading() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPastReading', Sort.asc);
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterSortBy> sortByIsPastReadingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPastReading', Sort.desc);
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterSortBy> sortByMangaDexId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mangaDexId', Sort.asc);
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterSortBy> sortByMangaDexIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mangaDexId', Sort.desc);
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterSortBy>
      sortBySessionDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionDurationMinutes', Sort.asc);
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterSortBy>
      sortBySessionDurationMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionDurationMinutes', Sort.desc);
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterSortBy> sortBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterSortBy> sortBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }
}

extension ReadingLogQuerySortThenBy
    on QueryBuilder<ReadingLog, ReadingLog, QSortThenBy> {
  QueryBuilder<ReadingLog, ReadingLog, QAfterSortBy> thenByChaptersRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chaptersRead', Sort.asc);
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterSortBy> thenByChaptersReadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chaptersRead', Sort.desc);
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterSortBy> thenByExactTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exactTimestamp', Sort.asc);
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterSortBy>
      thenByExactTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exactTimestamp', Sort.desc);
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterSortBy> thenByIsImported() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isImported', Sort.asc);
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterSortBy> thenByIsImportedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isImported', Sort.desc);
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterSortBy> thenByIsPastReading() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPastReading', Sort.asc);
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterSortBy> thenByIsPastReadingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPastReading', Sort.desc);
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterSortBy> thenByMangaDexId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mangaDexId', Sort.asc);
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterSortBy> thenByMangaDexIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mangaDexId', Sort.desc);
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterSortBy>
      thenBySessionDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionDurationMinutes', Sort.asc);
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterSortBy>
      thenBySessionDurationMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionDurationMinutes', Sort.desc);
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterSortBy> thenBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QAfterSortBy> thenBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }
}

extension ReadingLogQueryWhereDistinct
    on QueryBuilder<ReadingLog, ReadingLog, QDistinct> {
  QueryBuilder<ReadingLog, ReadingLog, QDistinct> distinctByChaptersRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chaptersRead');
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QDistinct> distinctByExactTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'exactTimestamp');
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QDistinct> distinctByIsImported() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isImported');
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QDistinct> distinctByIsPastReading() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPastReading');
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QDistinct> distinctByMangaDexId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mangaDexId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QDistinct>
      distinctBySessionDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionDurationMinutes');
    });
  }

  QueryBuilder<ReadingLog, ReadingLog, QDistinct> distinctBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionId');
    });
  }
}

extension ReadingLogQueryProperty
    on QueryBuilder<ReadingLog, ReadingLog, QQueryProperty> {
  QueryBuilder<ReadingLog, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ReadingLog, int, QQueryOperations> chaptersReadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chaptersRead');
    });
  }

  QueryBuilder<ReadingLog, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<ReadingLog, DateTime?, QQueryOperations>
      exactTimestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'exactTimestamp');
    });
  }

  QueryBuilder<ReadingLog, bool, QQueryOperations> isImportedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isImported');
    });
  }

  QueryBuilder<ReadingLog, bool, QQueryOperations> isPastReadingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPastReading');
    });
  }

  QueryBuilder<ReadingLog, String, QQueryOperations> mangaDexIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mangaDexId');
    });
  }

  QueryBuilder<ReadingLog, int, QQueryOperations>
      sessionDurationMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionDurationMinutes');
    });
  }

  QueryBuilder<ReadingLog, int?, QQueryOperations> sessionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionId');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const ReadingLogEntrySchema = Schema(
  name: r'ReadingLogEntry',
  id: -8898564799233365279,
  properties: {
    r'chaptersRead': PropertySchema(
      id: 0,
      name: r'chaptersRead',
      type: IsarType.long,
    ),
    r'date': PropertySchema(
      id: 1,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'mangaDexId': PropertySchema(
      id: 2,
      name: r'mangaDexId',
      type: IsarType.string,
    )
  },
  estimateSize: _readingLogEntryEstimateSize,
  serialize: _readingLogEntrySerialize,
  deserialize: _readingLogEntryDeserialize,
  deserializeProp: _readingLogEntryDeserializeProp,
);

int _readingLogEntryEstimateSize(
  ReadingLogEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.mangaDexId.length * 3;
  return bytesCount;
}

void _readingLogEntrySerialize(
  ReadingLogEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.chaptersRead);
  writer.writeDateTime(offsets[1], object.date);
  writer.writeString(offsets[2], object.mangaDexId);
}

ReadingLogEntry _readingLogEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ReadingLogEntry();
  object.chaptersRead = reader.readLong(offsets[0]);
  object.date = reader.readDateTime(offsets[1]);
  object.mangaDexId = reader.readString(offsets[2]);
  return object;
}

P _readingLogEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension ReadingLogEntryQueryFilter
    on QueryBuilder<ReadingLogEntry, ReadingLogEntry, QFilterCondition> {
  QueryBuilder<ReadingLogEntry, ReadingLogEntry, QAfterFilterCondition>
      chaptersReadEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chaptersRead',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingLogEntry, ReadingLogEntry, QAfterFilterCondition>
      chaptersReadGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chaptersRead',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingLogEntry, ReadingLogEntry, QAfterFilterCondition>
      chaptersReadLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chaptersRead',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingLogEntry, ReadingLogEntry, QAfterFilterCondition>
      chaptersReadBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chaptersRead',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingLogEntry, ReadingLogEntry, QAfterFilterCondition>
      dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingLogEntry, ReadingLogEntry, QAfterFilterCondition>
      dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingLogEntry, ReadingLogEntry, QAfterFilterCondition>
      dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingLogEntry, ReadingLogEntry, QAfterFilterCondition>
      dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingLogEntry, ReadingLogEntry, QAfterFilterCondition>
      mangaDexIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mangaDexId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingLogEntry, ReadingLogEntry, QAfterFilterCondition>
      mangaDexIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mangaDexId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingLogEntry, ReadingLogEntry, QAfterFilterCondition>
      mangaDexIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mangaDexId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingLogEntry, ReadingLogEntry, QAfterFilterCondition>
      mangaDexIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mangaDexId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingLogEntry, ReadingLogEntry, QAfterFilterCondition>
      mangaDexIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mangaDexId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingLogEntry, ReadingLogEntry, QAfterFilterCondition>
      mangaDexIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mangaDexId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingLogEntry, ReadingLogEntry, QAfterFilterCondition>
      mangaDexIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mangaDexId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingLogEntry, ReadingLogEntry, QAfterFilterCondition>
      mangaDexIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mangaDexId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingLogEntry, ReadingLogEntry, QAfterFilterCondition>
      mangaDexIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mangaDexId',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingLogEntry, ReadingLogEntry, QAfterFilterCondition>
      mangaDexIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mangaDexId',
        value: '',
      ));
    });
  }
}

extension ReadingLogEntryQueryObject
    on QueryBuilder<ReadingLogEntry, ReadingLogEntry, QFilterCondition> {}
