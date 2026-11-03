class Lock {
  final String id;
  final String serviceName;
  final String password;
  final DateTime startedAt;
  final DateTime expiresAt;

  Lock({
    required this.id,
    required this.serviceName,
    required this.password,
    required this.startedAt,
    required this.expiresAt,
  });

  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  Duration get remaining {
    final difference = expiresAt.difference(DateTime.now());

    if (difference.isNegative) {
      return Duration.zero;
    }

    return difference;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceName': serviceName,
      'password': password,
      'startedAt': startedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  factory Lock.fromJson(Map<String, dynamic> json) {
    return Lock(
      id: json['id'],
      serviceName: json['serviceName'],
      password: json['password'],
      startedAt: DateTime.parse(json['startedAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }
}