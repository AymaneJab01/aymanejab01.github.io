class Person {
  final String id;
  final String name;

  const Person({
    required this.id,
    required this.name,
  });

  Person copyWith({
    String? id,
    String? name,
  }) {
    return Person(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}