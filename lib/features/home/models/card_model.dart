import 'cred_model.dart';

class CardModel {
  const CardModel({
    required this.backgroundImageUrl,
    required this.cardArtUrl,
    required this.cardNumber,
    required this.cardholderName,
    required this.amount,
    required this.dueDate,
    required this.payButtonLabel,
    this.pendingActionLabel,
    this.pendingActionImageUrl,
    this.viewDetailsLabel,
  });

  final String backgroundImageUrl;
  final String cardArtUrl;
  final String cardNumber;
  final String cardholderName;
  final String amount;
  final String dueDate;
  final String payButtonLabel;
  final String? pendingActionLabel;
  final String? pendingActionImageUrl;
  final String? viewDetailsLabel;

  factory CardModel.fromResponseItem(Item item) {
    final body = item.templateProperties.body;
    final statement = body.statement;
    FlipperPill? pendingAction;
    FlipperPill? viewDetailsAction;

    for (final pill in body.flipperPill ?? const <FlipperPill>[]) {
      if (pill.type == FlipperPillType.PENDING_ACTION) {
        pendingAction = pill;
      } else if (pill.type == FlipperPillType.VIEW_DETAILS) {
        viewDetailsAction = pill;
      }
    }

    return CardModel(
      backgroundImageUrl: body.asset1?.url ?? '',
      cardArtUrl: body.asset3?.url ?? '',
      cardNumber: body.text3 ?? '',
      cardholderName: body.text4 ?? '',
      amount: statement?.text1 ?? '',
      dueDate: statement?.text2 ?? '',
      payButtonLabel: statement?.cta1.title ?? 'Pay now',
      pendingActionLabel: pendingAction?.cta1.title,
      pendingActionImageUrl: pendingAction?.cta1.asset?.url,
      viewDetailsLabel: viewDetailsAction?.cta1.title,
    );
  }

  String get plainPendingActionLabel =>
      pendingActionLabel?.replaceAll(RegExp(r'<[^>]*>'), '') ?? '';

  String get plainViewDetailsLabel =>
      viewDetailsLabel?.replaceAll(RegExp(r'<[^>]*>'), '') ?? 'View details';
}
