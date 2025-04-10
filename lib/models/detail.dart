class Detail {
  final String id;
  final String type;
  final String title;
  final List<String>? images;
  final String description;
  final String timeline;
  final String? organization;
  final String? location;
  final List<String>? tags;
  final String detailType;

  Detail({
    required this.id,
    required this.type,
    required this.title,
    this.images,
    required this.description,
    required this.timeline,
    this.organization,
    this.location,
    this.tags,
    required this.detailType,
  });

  factory Detail.fromJson(Map<String, dynamic> json) {
    return Detail(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      images: (json['images'] as List<dynamic>?)?.cast<String>(),
      description: json['description'],
      timeline: json['timeline'],
      organization: json['organization'],
      location: json['location'],
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
      detailType: json['detailType'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'title': title,
    'images': images,
    'description': description,
    'timeline': timeline,
    'organization': organization,
    'location': location,
    'tags': tags,
    'detailType': detailType,
  };

  Detail copyWith({
    String? id,
    String? type,
    String? title,
    List<String>? images,
    String? description,
    String? timeline,
    String? organization,
    String? location,
    List<String>? tags,
    String? detailType,
  }) {
    return Detail(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      images: images ?? this.images,
      description: description ?? this.description,
      timeline: timeline ?? this.timeline,
      organization: organization ?? this.organization,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      detailType: detailType ?? this.detailType,
    );
  }
}
