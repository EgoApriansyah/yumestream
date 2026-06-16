// GENERATED CODE - DO NOT MODIFY BY HAND
// Manual implementation of Hive TypeAdapters

part of 'watch_history_model.dart';

class WatchHistoryModelAdapter extends TypeAdapter<WatchHistoryModel> {
  @override
  final int typeId = 0;

  @override
  WatchHistoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WatchHistoryModel(
      animeId: fields[0] as String,
      animeTitle: fields[1] as String,
      poster: fields[2] as String,
      episodeId: fields[3] as String,
      episodeNumber: fields[4] as int,
      progress: fields[5] as double,
      timestamp: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WatchHistoryModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.animeId)
      ..writeByte(1)
      ..write(obj.animeTitle)
      ..writeByte(2)
      ..write(obj.poster)
      ..writeByte(3)
      ..write(obj.episodeId)
      ..writeByte(4)
      ..write(obj.episodeNumber)
      ..writeByte(5)
      ..write(obj.progress)
      ..writeByte(6)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchHistoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WatchlistItemModelAdapter extends TypeAdapter<WatchlistItemModel> {
  @override
  final int typeId = 1;

  @override
  WatchlistItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WatchlistItemModel(
      animeId: fields[0] as String,
      title: fields[1] as String,
      poster: fields[2] as String,
      score: fields[3] as String?,
      status: fields[4] as String?,
      addedAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WatchlistItemModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.animeId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.poster)
      ..writeByte(3)
      ..write(obj.score)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.addedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchlistItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
