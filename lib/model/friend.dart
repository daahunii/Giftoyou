class Friend {
  final String id;
  final String name;
  final String birthday;
  final String sns;
  final String photoUrl;

  Friend({
    required this.id,
    required this.name,
    required this.birthday,
    required this.sns,
    required this.photoUrl,
  });

  /// Firestore에서 가져올 때
  factory Friend.fromMap(String id, Map<String, dynamic> data) {
    return Friend(
      id: id,
      name: data['name'] ?? '',
      birthday: data['birthday'] ?? '',
      sns: data['sns'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
    );
  }

  /// Firestore에 저장할 때
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'birthday': birthday,
      'sns': sns,
      'photoUrl': photoUrl,
    };
  }

  /// 일부 필드만 수정한 새 인스턴스를 반환
  Friend copyWith({
    String? id,
    String? name,
    String? birthday,
    String? sns,
    String? photoUrl,
  }) {
    return Friend(
      id: id ?? this.id,
      name: name ?? this.name,
      birthday: birthday ?? this.birthday,
      sns: sns ?? this.sns,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}