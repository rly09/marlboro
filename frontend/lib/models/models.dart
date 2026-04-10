class Report {
  final int id;
  final double lat;
  final double lng;
  final String severity;
  final String status;
  final String img;
  final String description;
  final String? aiInsight;
  final String? afterImg;
  final String? claimedByName;

  Report({
    required this.id,
    required this.lat,
    required this.lng,
    required this.severity,
    required this.status,
    required this.img,
    required this.description,
    this.aiInsight,
    this.afterImg,
    this.claimedByName,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      severity: json['severity'],
      status: json['status'],
      img: json['img'],
      description: json['description'],
      aiInsight: json['aiInsight'],
      afterImg: json['after_img'],
      claimedByName: json['claimed_by_name'],
    );
  }

  Report copyWith({String? status}) {
    return Report(
      id: id,
      lat: lat,
      lng: lng,
      severity: severity,
      status: status ?? this.status,
      img: img,
      description: description,
      aiInsight: aiInsight,
      afterImg: afterImg,
      claimedByName: claimedByName,
    );
  }
}

class UserStats {
  final String name;
  final int points;
  final int streak;
  final List<String> badges;
  final int trustScore;
  final int totalCleanups;

  UserStats({
    required this.name,
    required this.points,
    required this.streak,
    required this.badges,
    required this.trustScore,
    required this.totalCleanups,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      name: json['name'],
      points: json['points'],
      streak: json['streak'],
      badges: List<String>.from(json['badges'] ?? []),
      trustScore: json['trust_score'] ?? 100,
      totalCleanups: json['total_cleanups'] ?? 0,
    );
  }

  UserStats copyWith({int? points, int? trustScore, int? totalCleanups}) {
    return UserStats(
      name: name,
      points: points ?? this.points,
      streak: streak,
      badges: badges,
      trustScore: trustScore ?? this.trustScore,
      totalCleanups: totalCleanups ?? this.totalCleanups,
    );
  }
}

class LeaderboardEntry {
  final String name;
  final int points;
  final String badge;
  final bool isMe;
  final int trustScore;
  final int totalCleanups;

  LeaderboardEntry({
    required this.name,
    required this.points,
    required this.badge,
    required this.isMe,
    required this.trustScore,
    required this.totalCleanups,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      name: json['name'],
      points: json['points'],
      badge: json['badge'],
      isMe: json['isMe'] ?? false,
      trustScore: json['trust_score'] ?? 100,
      totalCleanups: json['total_cleanups'] ?? 0,
    );
  }
}
