import 'package:freezed_annotation/freezed_annotation.dart';

part 'page.freezed.dart';

@freezed
class Page<T> with _$Page<T> {
  const factory Page({
    required int lastPage,
    required List<T> elements,
  }) = _Page<T>;
}
