// Exercise 16: The breakdown that is always empty
//
// json_serializable looks for a key named after the Dart field. The field is
// `breakdown`; the API sends `breakdown_lines`. No key matches, so the value is
// null - and null is legal for List<String>?, so nothing ever complains.
//
// Map the name with @JsonKey, then regenerate:
//   dart run build_runner build --delete-conflicting-outputs
//
// Worth noticing: if the field were non-nullable you would have got a loud
// error on the first response instead of silent data loss.

@JsonSerializable()
class Quote {
  const Quote({required this.id, required this.premium, this.breakdown});

  final String id;
  final double premium;

  @JsonKey(name: 'breakdown_lines')      // was missing
  final List<String>? breakdown;

  factory Quote.fromJson(Map<String, dynamic> json) => _$QuoteFromJson(json);
  Map<String, dynamic> toJson() => _$QuoteToJson(this);
}
