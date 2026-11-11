class CardActionModel {
  const CardActionModel({
    required this.id,
    required this.label,
    required this.icon,
    required this.action,
  });

  final String id;
  final String label;
  final String icon;
  final String action;

  factory CardActionModel.fromJson(Map<String, dynamic> json) {
    return CardActionModel(
      id: json['id'] as String,
      label: json['label'] as String,
      icon: json['icon'] as String,
      action: json['action'] as String,
    );
  }
}
