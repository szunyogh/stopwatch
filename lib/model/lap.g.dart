// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lap.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LapModel _$LapModelFromJson(Map<String, dynamic> json) => _LapModel(
  time: json['time'] == null
      ? Duration.zero
      : const DurationConverter().fromJson((json['time'] as num).toInt()),
  totalTime: json['totalTime'] == null
      ? Duration.zero
      : const DurationConverter().fromJson((json['totalTime'] as num).toInt()),
  order: (json['order'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$LapModelToJson(_LapModel instance) => <String, dynamic>{
  'time': const DurationConverter().toJson(instance.time),
  'totalTime': const DurationConverter().toJson(instance.totalTime),
  'order': instance.order,
};
