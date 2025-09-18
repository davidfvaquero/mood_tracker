// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enhanced_mood_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EnhancedMoodEntryAdapter extends TypeAdapter<EnhancedMoodEntry> {
  @override
  final int typeId = 1;

  @override
  EnhancedMoodEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EnhancedMoodEntry(
      date: fields[0] as DateTime,
      overallMood: fields[1] as int,
      emotions: (fields[2] as Map).cast<String, int>(),
      activities: (fields[3] as List).cast<String>(),
      notes: fields[4] as String?,
      energyLevel: fields[5] as int,
      stressLevel: fields[6] as int,
      triggers: (fields[7] as List).cast<String>(),
      location: fields[8] as String?,
      isQuickEntry: fields[9] as bool,
      reminderTime: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, EnhancedMoodEntry obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.overallMood)
      ..writeByte(2)
      ..write(obj.emotions)
      ..writeByte(3)
      ..write(obj.activities)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.energyLevel)
      ..writeByte(6)
      ..write(obj.stressLevel)
      ..writeByte(7)
      ..write(obj.triggers)
      ..writeByte(8)
      ..write(obj.location)
      ..writeByte(9)
      ..write(obj.isQuickEntry)
      ..writeByte(10)
      ..write(obj.reminderTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnhancedMoodEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
