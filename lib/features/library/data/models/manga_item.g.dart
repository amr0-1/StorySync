// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_item.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMangaItemCollection on Isar {
  IsarCollection<MangaItem> get mangaItems => this.collection();
}

const MangaItemSchema = CollectionSchema(
  name: r'MangaItem',
  id: 6638099258669080880,
  properties: {
    r'author': PropertySchema(
      id: 0,
      name: r'author',
      type: IsarType.string,
    ),
    r'chapterProgress': PropertySchema(
      id: 1,
      name: r'chapterProgress',
      type: IsarType.long,
    ),
    r'coverUrl': PropertySchema(
      id: 2,
      name: r'coverUrl',
      type: IsarType.string,
    ),
    r'hasCustomMetadata': PropertySchema(
      id: 3,
      name: r'hasCustomMetadata',
      type: IsarType.bool,
    ),
    r'lastUpdated': PropertySchema(
      id: 4,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'mangaDexId': PropertySchema(
      id: 5,
      name: r'mangaDexId',
      type: IsarType.string,
    ),
    r'progress': PropertySchema(
      id: 6,
      name: r'progress',
      type: IsarType.double,
    ),
    r'progressPercent': PropertySchema(
      id: 7,
      name: r'progressPercent',
      type: IsarType.long,
    ),
    r'readingStatus': PropertySchema(
      id: 8,
      name: r'readingStatus',
      type: IsarType.byte,
      enumMap: _MangaItemreadingStatusEnumValueMap,
    ),
    r'remainingChapters': PropertySchema(
      id: 9,
      name: r'remainingChapters',
      type: IsarType.long,
    ),
    r'source': PropertySchema(
      id: 10,
      name: r'source',
      type: IsarType.string,
    ),
    r'synopsis': PropertySchema(
      id: 11,
      name: r'synopsis',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 12,
      name: r'title',
      type: IsarType.string,
    ),
    r'totalChapters': PropertySchema(
      id: 13,
      name: r'totalChapters',
      type: IsarType.long,
    )
  },
  estimateSize: _mangaItemEstimateSize,
  serialize: _mangaItemSerialize,
  deserialize: _mangaItemDeserialize,
  deserializeProp: _mangaItemDeserializeProp,
  idName: r'id',
  indexes: {
    r'mangaDexId': IndexSchema(
      id: -2561072137442709649,
      name: r'mangaDexId',
      unique: true,
      replace: true,
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
  getId: _mangaItemGetId,
  getLinks: _mangaItemGetLinks,
  attach: _mangaItemAttach,
  version: '3.1.0+1',
);

int _mangaItemEstimateSize(
  MangaItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.author;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.coverUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.mangaDexId.length * 3;
  bytesCount += 3 + object.source.length * 3;
  {
    final value = object.synopsis;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _mangaItemSerialize(
  MangaItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.author);
  writer.writeLong(offsets[1], object.chapterProgress);
  writer.writeString(offsets[2], object.coverUrl);
  writer.writeBool(offsets[3], object.hasCustomMetadata);
  writer.writeDateTime(offsets[4], object.lastUpdated);
  writer.writeString(offsets[5], object.mangaDexId);
  writer.writeDouble(offsets[6], object.progress);
  writer.writeLong(offsets[7], object.progressPercent);
  writer.writeByte(offsets[8], object.readingStatus.index);
  writer.writeLong(offsets[9], object.remainingChapters);
  writer.writeString(offsets[10], object.source);
  writer.writeString(offsets[11], object.synopsis);
  writer.writeString(offsets[12], object.title);
  writer.writeLong(offsets[13], object.totalChapters);
}

MangaItem _mangaItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MangaItem();
  object.author = reader.readStringOrNull(offsets[0]);
  object.chapterProgress = reader.readLong(offsets[1]);
  object.coverUrl = reader.readStringOrNull(offsets[2]);
  object.hasCustomMetadata = reader.readBool(offsets[3]);
  object.id = id;
  object.lastUpdated = reader.readDateTime(offsets[4]);
  object.mangaDexId = reader.readString(offsets[5]);
  object.readingStatus =
      _MangaItemreadingStatusValueEnumMap[reader.readByteOrNull(offsets[8])] ??
          ReadingStatus.reading;
  object.source = reader.readString(offsets[10]);
  object.synopsis = reader.readStringOrNull(offsets[11]);
  object.title = reader.readString(offsets[12]);
  object.totalChapters = reader.readLongOrNull(offsets[13]);
  return object;
}

P _mangaItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (_MangaItemreadingStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          ReadingStatus.reading) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _MangaItemreadingStatusEnumValueMap = {
  'reading': 0,
  'completed': 1,
  'onHold': 2,
  'planToRead': 3,
  'dropped': 4,
};
const _MangaItemreadingStatusValueEnumMap = {
  0: ReadingStatus.reading,
  1: ReadingStatus.completed,
  2: ReadingStatus.onHold,
  3: ReadingStatus.planToRead,
  4: ReadingStatus.dropped,
};

Id _mangaItemGetId(MangaItem object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _mangaItemGetLinks(MangaItem object) {
  return [];
}

void _mangaItemAttach(IsarCollection<dynamic> col, Id id, MangaItem object) {
  object.id = id;
}

extension MangaItemByIndex on IsarCollection<MangaItem> {
  Future<MangaItem?> getByMangaDexId(String mangaDexId) {
    return getByIndex(r'mangaDexId', [mangaDexId]);
  }

  MangaItem? getByMangaDexIdSync(String mangaDexId) {
    return getByIndexSync(r'mangaDexId', [mangaDexId]);
  }

  Future<bool> deleteByMangaDexId(String mangaDexId) {
    return deleteByIndex(r'mangaDexId', [mangaDexId]);
  }

  bool deleteByMangaDexIdSync(String mangaDexId) {
    return deleteByIndexSync(r'mangaDexId', [mangaDexId]);
  }

  Future<List<MangaItem?>> getAllByMangaDexId(List<String> mangaDexIdValues) {
    final values = mangaDexIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'mangaDexId', values);
  }

  List<MangaItem?> getAllByMangaDexIdSync(List<String> mangaDexIdValues) {
    final values = mangaDexIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'mangaDexId', values);
  }

  Future<int> deleteAllByMangaDexId(List<String> mangaDexIdValues) {
    final values = mangaDexIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'mangaDexId', values);
  }

  int deleteAllByMangaDexIdSync(List<String> mangaDexIdValues) {
    final values = mangaDexIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'mangaDexId', values);
  }

  Future<Id> putByMangaDexId(MangaItem object) {
    return putByIndex(r'mangaDexId', object);
  }

  Id putByMangaDexIdSync(MangaItem object, {bool saveLinks = true}) {
    return putByIndexSync(r'mangaDexId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByMangaDexId(List<MangaItem> objects) {
    return putAllByIndex(r'mangaDexId', objects);
  }

  List<Id> putAllByMangaDexIdSync(List<MangaItem> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'mangaDexId', objects, saveLinks: saveLinks);
  }
}

extension MangaItemQueryWhereSort
    on QueryBuilder<MangaItem, MangaItem, QWhere> {
  QueryBuilder<MangaItem, MangaItem, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MangaItemQueryWhere
    on QueryBuilder<MangaItem, MangaItem, QWhereClause> {
  QueryBuilder<MangaItem, MangaItem, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<MangaItem, MangaItem, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterWhereClause> idBetween(
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

  QueryBuilder<MangaItem, MangaItem, QAfterWhereClause> mangaDexIdEqualTo(
      String mangaDexId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'mangaDexId',
        value: [mangaDexId],
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterWhereClause> mangaDexIdNotEqualTo(
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

extension MangaItemQueryFilter
    on QueryBuilder<MangaItem, MangaItem, QFilterCondition> {
  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> authorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'author',
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> authorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'author',
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> authorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> authorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> authorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> authorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'author',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> authorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> authorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> authorContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> authorMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'author',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> authorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'author',
        value: '',
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> authorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'author',
        value: '',
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition>
      chapterProgressEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterProgress',
        value: value,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition>
      chapterProgressGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chapterProgress',
        value: value,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition>
      chapterProgressLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chapterProgress',
        value: value,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition>
      chapterProgressBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chapterProgress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> coverUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'coverUrl',
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition>
      coverUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'coverUrl',
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> coverUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coverUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> coverUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'coverUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> coverUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'coverUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> coverUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'coverUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> coverUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'coverUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> coverUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'coverUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> coverUrlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'coverUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> coverUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'coverUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> coverUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coverUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition>
      coverUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'coverUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition>
      hasCustomMetadataEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasCustomMetadata',
        value: value,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> idBetween(
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

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> lastUpdatedEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition>
      lastUpdatedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> lastUpdatedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> lastUpdatedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUpdated',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> mangaDexIdEqualTo(
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

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition>
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

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> mangaDexIdLessThan(
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

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> mangaDexIdBetween(
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

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition>
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

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> mangaDexIdEndsWith(
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

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> mangaDexIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mangaDexId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> mangaDexIdMatches(
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

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition>
      mangaDexIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mangaDexId',
        value: '',
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition>
      mangaDexIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mangaDexId',
        value: '',
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> progressEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'progress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> progressGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'progress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> progressLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'progress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> progressBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'progress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition>
      progressPercentEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'progressPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition>
      progressPercentGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'progressPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition>
      progressPercentLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'progressPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition>
      progressPercentBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'progressPercent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition>
      readingStatusEqualTo(ReadingStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'readingStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition>
      readingStatusGreaterThan(
    ReadingStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'readingStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition>
      readingStatusLessThan(
    ReadingStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'readingStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition>
      readingStatusBetween(
    ReadingStatus lower,
    ReadingStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'readingStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition>
      remainingChaptersEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remainingChapters',
        value: value,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition>
      remainingChaptersGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'remainingChapters',
        value: value,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition>
      remainingChaptersLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'remainingChapters',
        value: value,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition>
      remainingChaptersBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'remainingChapters',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> sourceEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> sourceGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> sourceLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> sourceBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'source',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> sourceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> sourceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> sourceContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> sourceMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'source',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> sourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> sourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> synopsisIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'synopsis',
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition>
      synopsisIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'synopsis',
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> synopsisEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'synopsis',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> synopsisGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'synopsis',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> synopsisLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'synopsis',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> synopsisBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'synopsis',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> synopsisStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'synopsis',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> synopsisEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'synopsis',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> synopsisContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'synopsis',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> synopsisMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'synopsis',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> synopsisIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'synopsis',
        value: '',
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition>
      synopsisIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'synopsis',
        value: '',
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> titleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> titleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition>
      totalChaptersIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'totalChapters',
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition>
      totalChaptersIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'totalChapters',
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition>
      totalChaptersEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalChapters',
        value: value,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition>
      totalChaptersGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalChapters',
        value: value,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition>
      totalChaptersLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalChapters',
        value: value,
      ));
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterFilterCondition>
      totalChaptersBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalChapters',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MangaItemQueryObject
    on QueryBuilder<MangaItem, MangaItem, QFilterCondition> {}

extension MangaItemQueryLinks
    on QueryBuilder<MangaItem, MangaItem, QFilterCondition> {}

extension MangaItemQuerySortBy on QueryBuilder<MangaItem, MangaItem, QSortBy> {
  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> sortByAuthor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.asc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> sortByAuthorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.desc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> sortByChapterProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterProgress', Sort.asc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> sortByChapterProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterProgress', Sort.desc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> sortByCoverUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverUrl', Sort.asc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> sortByCoverUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverUrl', Sort.desc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> sortByHasCustomMetadata() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasCustomMetadata', Sort.asc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy>
      sortByHasCustomMetadataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasCustomMetadata', Sort.desc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> sortByMangaDexId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mangaDexId', Sort.asc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> sortByMangaDexIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mangaDexId', Sort.desc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> sortByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.asc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> sortByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.desc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> sortByProgressPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progressPercent', Sort.asc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> sortByProgressPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progressPercent', Sort.desc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> sortByReadingStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readingStatus', Sort.asc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> sortByReadingStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readingStatus', Sort.desc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> sortByRemainingChapters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remainingChapters', Sort.asc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy>
      sortByRemainingChaptersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remainingChapters', Sort.desc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> sortBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> sortBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> sortBySynopsis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synopsis', Sort.asc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> sortBySynopsisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synopsis', Sort.desc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> sortByTotalChapters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalChapters', Sort.asc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> sortByTotalChaptersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalChapters', Sort.desc);
    });
  }
}

extension MangaItemQuerySortThenBy
    on QueryBuilder<MangaItem, MangaItem, QSortThenBy> {
  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> thenByAuthor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.asc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> thenByAuthorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.desc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> thenByChapterProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterProgress', Sort.asc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> thenByChapterProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterProgress', Sort.desc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> thenByCoverUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverUrl', Sort.asc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> thenByCoverUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverUrl', Sort.desc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> thenByHasCustomMetadata() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasCustomMetadata', Sort.asc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy>
      thenByHasCustomMetadataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasCustomMetadata', Sort.desc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> thenByMangaDexId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mangaDexId', Sort.asc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> thenByMangaDexIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mangaDexId', Sort.desc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> thenByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.asc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> thenByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.desc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> thenByProgressPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progressPercent', Sort.asc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> thenByProgressPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progressPercent', Sort.desc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> thenByReadingStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readingStatus', Sort.asc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> thenByReadingStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readingStatus', Sort.desc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> thenByRemainingChapters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remainingChapters', Sort.asc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy>
      thenByRemainingChaptersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remainingChapters', Sort.desc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> thenBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> thenBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> thenBySynopsis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synopsis', Sort.asc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> thenBySynopsisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synopsis', Sort.desc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> thenByTotalChapters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalChapters', Sort.asc);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QAfterSortBy> thenByTotalChaptersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalChapters', Sort.desc);
    });
  }
}

extension MangaItemQueryWhereDistinct
    on QueryBuilder<MangaItem, MangaItem, QDistinct> {
  QueryBuilder<MangaItem, MangaItem, QDistinct> distinctByAuthor(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'author', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QDistinct> distinctByChapterProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chapterProgress');
    });
  }

  QueryBuilder<MangaItem, MangaItem, QDistinct> distinctByCoverUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'coverUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QDistinct> distinctByHasCustomMetadata() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasCustomMetadata');
    });
  }

  QueryBuilder<MangaItem, MangaItem, QDistinct> distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<MangaItem, MangaItem, QDistinct> distinctByMangaDexId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mangaDexId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QDistinct> distinctByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'progress');
    });
  }

  QueryBuilder<MangaItem, MangaItem, QDistinct> distinctByProgressPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'progressPercent');
    });
  }

  QueryBuilder<MangaItem, MangaItem, QDistinct> distinctByReadingStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'readingStatus');
    });
  }

  QueryBuilder<MangaItem, MangaItem, QDistinct> distinctByRemainingChapters() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remainingChapters');
    });
  }

  QueryBuilder<MangaItem, MangaItem, QDistinct> distinctBySource(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'source', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QDistinct> distinctBySynopsis(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'synopsis', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MangaItem, MangaItem, QDistinct> distinctByTotalChapters() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalChapters');
    });
  }
}

extension MangaItemQueryProperty
    on QueryBuilder<MangaItem, MangaItem, QQueryProperty> {
  QueryBuilder<MangaItem, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MangaItem, String?, QQueryOperations> authorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'author');
    });
  }

  QueryBuilder<MangaItem, int, QQueryOperations> chapterProgressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chapterProgress');
    });
  }

  QueryBuilder<MangaItem, String?, QQueryOperations> coverUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'coverUrl');
    });
  }

  QueryBuilder<MangaItem, bool, QQueryOperations> hasCustomMetadataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasCustomMetadata');
    });
  }

  QueryBuilder<MangaItem, DateTime, QQueryOperations> lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<MangaItem, String, QQueryOperations> mangaDexIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mangaDexId');
    });
  }

  QueryBuilder<MangaItem, double, QQueryOperations> progressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'progress');
    });
  }

  QueryBuilder<MangaItem, int, QQueryOperations> progressPercentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'progressPercent');
    });
  }

  QueryBuilder<MangaItem, ReadingStatus, QQueryOperations>
      readingStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'readingStatus');
    });
  }

  QueryBuilder<MangaItem, int, QQueryOperations> remainingChaptersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remainingChapters');
    });
  }

  QueryBuilder<MangaItem, String, QQueryOperations> sourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'source');
    });
  }

  QueryBuilder<MangaItem, String?, QQueryOperations> synopsisProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'synopsis');
    });
  }

  QueryBuilder<MangaItem, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<MangaItem, int?, QQueryOperations> totalChaptersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalChapters');
    });
  }
}
