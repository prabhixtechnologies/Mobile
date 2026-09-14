//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'change_seats_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ChangeSeatsRequest {
  /// Returns a new [ChangeSeatsRequest] instance.
  ChangeSeatsRequest({

    required  this.seats,
  });

          // minimum: 1
          // maximum: 10000
  @JsonKey(
    
    name: r'seats',
    required: true,
    includeIfNull: false,
  )


  final int seats;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ChangeSeatsRequest &&
      other.seats == seats;

    @override
    int get hashCode =>
        seats.hashCode;

  factory ChangeSeatsRequest.fromJson(Map<String, dynamic> json) => _$ChangeSeatsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ChangeSeatsRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

