import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:job_hive/features/home/models/card_action_model.dart';
import 'package:job_hive/features/home/models/credit_card_model.dart';

class CardDetailsController extends GetxController {
  CardDetailsController({required this.card});

  final CreditCardModel card;

  List<CardActionModel> get quickActions => card.actions
      .where(
        (action) =>
            action.action == 'mark_paid' || action.action == 'payment_history',
      )
      .toList(growable: false);

  List<Map<String, String>> get detailRows => card.detailRows;

  List<Map<String, String>> get history => card.history;

  String get activityDate => card.activityDate;

  List<Map<String, String>> get activityRows => card.activityRows;

  Color get themeColor {
    final value = card.themeColor.replaceFirst('#', '');
    final parsed = int.tryParse(value, radix: 16) ?? 0xB00050;
    return Color(value.length <= 6 ? 0xFF000000 | parsed : parsed);
  }

  IconData iconForAction(String icon) {
    return switch (icon) {
      'check_circle' => Icons.check_circle_outline,
      'receipt_long' => Icons.receipt_long,
      'history' => Icons.history,
      'local_offer' => Icons.local_offer_outlined,
      'tune' => Icons.tune,
      'manage_search' => Icons.manage_search,
      'currency_rupee' => Icons.currency_rupee,
      'percent' => Icons.percent,
      _ => Icons.credit_card,
    };
  }
}
