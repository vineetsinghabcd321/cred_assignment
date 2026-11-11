import 'card_action_model.dart';
import 'card_model.dart';

class CreditCardModel {
  const CreditCardModel({
    required this.id,
    required this.bankName,
    required this.cardholderName,
    required this.cardNumber,
    required this.dueAmount,
    required this.dueDate,
    required this.backgroundImageUrl,
    required this.cardArtUrl,
    required this.themeColor,
    required this.actions,
    required this.detailRows,
    required this.history,
    this.activityDate = '',
    this.activityRows = const [],
    this.pendingActionLabel,
    this.pendingActionImageUrl,
    this.viewDetailsLabel,
    this.payButtonLabel = 'Pay now',
  });

  final String id;
  final String bankName;
  final String cardholderName;
  final String cardNumber;
  final String dueAmount;
  final String dueDate;
  final String backgroundImageUrl;
  final String cardArtUrl;
  final String themeColor;
  final List<CardActionModel> actions;
  final List<Map<String, String>> detailRows;
  final List<Map<String, String>> history;
  final String activityDate;
  final List<Map<String, String>> activityRows;
  final String? pendingActionLabel;
  final String? pendingActionImageUrl;
  final String? viewDetailsLabel;
  final String payButtonLabel;

  factory CreditCardModel.fromJson(
    Map<String, dynamic> json, {
    List<CardActionModel> actions = const [],
  }) {
    final properties = Map<String, dynamic>.from(
      json['template_properties'] as Map,
    );
    final body = Map<String, dynamic>.from(properties['body'] as Map);
    final statement = body['statement'] is Map
        ? Map<String, dynamic>.from(body['statement'] as Map)
        : <String, dynamic>{};
    final uiData = body['card_ui'] is Map
        ? Map<String, dynamic>.from(body['card_ui'] as Map)
        : <String, dynamic>{};
    final flipperPills = (body['flipper_pill'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((pill) => Map<String, dynamic>.from(pill))
        .toList(growable: false);
    final pendingAction = _actionOfType(flipperPills, 'pending_action');
    final viewDetails = _actionOfType(flipperPills, 'view_details');
    final cta1 = statement['cta_1'] is Map
        ? Map<String, dynamic>.from(statement['cta_1'] as Map)
        : <String, dynamic>{};
    final background = body['asset_1'] is Map
        ? Map<String, dynamic>.from(body['asset_1'] as Map)
        : <String, dynamic>{};
    final cardArt = body['asset_3'] is Map
        ? Map<String, dynamic>.from(body['asset_3'] as Map)
        : <String, dynamic>{};
    final pendingCta = pendingAction?['cta_1'] is Map
        ? Map<String, dynamic>.from(pendingAction!['cta_1'] as Map)
        : <String, dynamic>{};
    final pendingAsset = pendingCta['asset'] is Map
        ? Map<String, dynamic>.from(pendingCta['asset'] as Map)
        : <String, dynamic>{};
    final detailRows = _stringMaps(uiData['detail_rows']);
    final history = _stringMaps(uiData['payment_history']);
    final activityDate = (uiData['activity_date'] ?? '').toString();
    final activityRows = _stringMaps(uiData['activity_rows']);

    return CreditCardModel(
      id: (body['instrument_id'] ?? json['external_id'] ?? body['text_3'])
          .toString(),
      bankName: (uiData['bank_name'] ?? '').toString(),
      cardholderName: (body['text_4'] ?? '').toString(),
      cardNumber: (body['text_3'] ?? '').toString(),
      dueAmount: (statement['text_1'] ?? '').toString(),
      dueDate: (statement['text_2'] ?? '').toString(),
      backgroundImageUrl: (background['url'] ?? '').toString(),
      cardArtUrl: (cardArt['url'] ?? '').toString(),
      themeColor: (uiData['theme_color'] ?? '#B00050').toString(),
      actions: actions,
      detailRows: detailRows,
      history: history,
      activityDate: activityDate,
      activityRows: activityRows,
      pendingActionLabel: pendingCta['title']?.toString(),
      pendingActionImageUrl: pendingAsset['url']?.toString(),
      viewDetailsLabel: _actionCta(viewDetails)?['title']?.toString(),
      payButtonLabel: (cta1['title'] ?? 'Pay now').toString(),
    );
  }

  CardModel toCardModel() {
    return CardModel(
      backgroundImageUrl: backgroundImageUrl,
      cardArtUrl: cardArtUrl,
      cardNumber: cardNumber,
      cardholderName: cardholderName,
      amount: dueAmount,
      dueDate: dueDate,
      payButtonLabel: payButtonLabel,
      pendingActionLabel: pendingActionLabel,
      pendingActionImageUrl: pendingActionImageUrl,
      viewDetailsLabel: viewDetailsLabel,
    );
  }

  static Map<String, dynamic>? _actionOfType(
    List<Map<String, dynamic>> pills,
    String type,
  ) {
    for (final pill in pills) {
      if (pill['type'] == type) return pill;
    }
    return null;
  }

  static Map<String, dynamic>? _actionCta(Map<String, dynamic>? action) {
    if (action?['cta_1'] is! Map) return null;
    return Map<String, dynamic>.from(action!['cta_1'] as Map);
  }

  static List<Map<String, String>> _stringMaps(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map(
          (row) => Map<String, String>.fromEntries(
            row.entries.map(
              (entry) => MapEntry(entry.key.toString(), entry.value.toString()),
            ),
          ),
        )
        .toList(growable: false);
  }
}
