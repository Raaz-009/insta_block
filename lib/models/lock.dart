class Lock {
  final String id, serviceName;
  final List<String> appNames, packageNames;
  final String? passwordKey;
  final bool passwordProtected;
  final DateTime startedAt, expiresAt;
  Lock({required this.id, required this.serviceName, required this.appNames, required this.packageNames, required this.passwordKey, required this.passwordProtected, required this.startedAt, required this.expiresAt});
  bool get isExpired => !DateTime.now().isBefore(expiresAt);
  Duration get remaining { final d=expiresAt.difference(DateTime.now()); return d.isNegative?Duration.zero:d; }
  Map<String,dynamic> toJson()=>{'id':id,'serviceName':serviceName,'appNames':appNames,'packageNames':packageNames,'passwordKey':passwordKey,'passwordProtected':passwordProtected,'startedAt':startedAt.toIso8601String(),'expiresAt':expiresAt.toIso8601String()};
  factory Lock.fromJson(Map<String,dynamic> j)=>Lock(id:j['id'],serviceName:j['serviceName'],appNames:List<String>.from(j['appNames']??[]),packageNames:List<String>.from(j['packageNames']??[]),passwordKey:j['passwordKey'],passwordProtected:j['passwordProtected']==true,startedAt:DateTime.parse(j['startedAt']),expiresAt:DateTime.parse(j['expiresAt']));
}
