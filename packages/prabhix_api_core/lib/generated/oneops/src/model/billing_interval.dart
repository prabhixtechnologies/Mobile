//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum BillingInterval {
      @JsonValue(r'MONTHLY')
      MONTHLY(r'MONTHLY'),
      @JsonValue(r'ANNUAL')
      ANNUAL(r'ANNUAL'),
      @JsonValue(r'ONE_TIME')
      ONE_TIME(r'ONE_TIME');

  const BillingInterval(this.value);

  final String value;

  @override
  String toString() => value;
}
