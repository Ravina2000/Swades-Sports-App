class Venue {
  const Venue({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.description,
  });

  final int id;
  final String name;
  final String type;
  final String location;
  final String description;

  factory Venue.fromJson(Map<String, dynamic> json) => Venue(
        id: json['id'] as int,
        name: json['name'] as String,
        type: json['type'] as String,
        location: json['location'] as String,
        description: json['description'] as String? ?? '',
      );

  bool get isBadminton => type == 'badminton';
}
