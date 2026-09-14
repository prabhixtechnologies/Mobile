//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payment_method_view.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PaymentMethodView {
  /// Returns a new [PaymentMethodView] instance.
  PaymentMethodView({

     this.method,

     this.label,

     this.lastUsedAt,

     this.vaulted,
  });

  @JsonKey(
    
    name: r'method',
    required: false,
    includeIfNull: false,
  )


  final String? method;



  @JsonKey(
    
    name: r'label',
    required: false,
    includeIfNull: false,
  )


  final String? label;



  @JsonKey(
    
    name: r'lastUsedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? lastUsedAt;



  @JsonKey(
    
    name: r'vaulted',
    required: false,
    includeIfNull: false,
  )


  final bool? vaulted;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PaymentMethodView &&
      other.method == method &&
      other.label == label &&
      other.lastUsedAt == lastUsedAt &&
      other.vaulted == vaulted;

    @override
    int get hashCode =>
        method.hashCode +
        label.hashCode +
        lastUsedAt.hashCode +
        vaulted.hashCode;

  factory PaymentMethodView.fromJson(Map<String, dynamic> json) => _$PaymentMethodViewFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentMethodViewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

