// Round-trip helpers — the project's @JsonSerializable classes do NOT use
// `explicitToJson: true`, so a naive `Foo.fromJson(foo.toJson())` leaves
// nested objects as live references and blows up the generated cast.
//
// Production uses `jsonEncode(foo.toJson())` to flatten the tree on the way
// to disk; these helpers mirror that pipeline so tests catch the same bugs.
import "dart:convert" show jsonDecode, jsonEncode;

/// Serialise [object] through real JSON (string form) and deserialise it
/// using [fromJson]. Use this whenever a model nests another @JsonSerializable.
T roundTripJson<T>(
  T object,
  T Function(Map<String, dynamic>) fromJson,
  dynamic Function(T) toJson,
) {
  final encoded = jsonEncode(toJson(object));
  final decoded = jsonDecode(encoded) as Map<String, dynamic>;
  return fromJson(decoded);
}

/// Convenience: round-trip an object whose [toJson] is a method on itself.
/// Cuts the call site to one line for the common case.
T roundTrip<T>(
  T object,
  T Function(Map<String, dynamic>) fromJson, {
  required Map<String, dynamic> Function(T) toJson,
}) =>
    roundTripJson(object, fromJson, toJson);
