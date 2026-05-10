class Event {
  final int id;
  final String title;
  final String? description;
  final String date;
  final String location;
  final int capacity;
  final int inscriptionsCount;

  Event({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    required this.location,
    required this.capacity,
    this.inscriptionsCount = 0,
  });

  int get placesRestantes => capacity - inscriptionsCount;
  bool get isComplet => placesRestantes <= 0;

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: json['date'],
      location: json['location'],
      capacity: json['capacity'],
      inscriptionsCount: json['inscriptions_count'] ?? 0,
    );
  }
}