//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum DiscountType {
      @JsonValue(r'PERCENTAGE')
      PERCENTAGE(r'PERCENTAGE'),
      @JsonValue(r'FIXED_AMOUNT')
      FIXED_AMOUNT(r'FIXED_AMOUNT');

  const DiscountType(this.value);

  final String value;

  @override
  String toString() => value;
}
