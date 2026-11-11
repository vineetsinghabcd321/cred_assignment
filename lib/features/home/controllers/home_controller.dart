import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:job_hive/features/home/models/card_action_model.dart';
import 'package:job_hive/features/home/models/card_model.dart';
import 'package:job_hive/features/home/models/credit_card_model.dart';
import 'package:job_hive/features/home/models/cred_model.dart';
import 'package:job_hive/features/home/service/home_service.dart';

class HomeController extends GetxController {
  HomeController({required HomeService homeService})
    : _homeService = homeService;

  final HomeService _homeService;
  final items = <Item>[].obs;
  final cardActions = <CardActionModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final selectedTab = 0.obs;
  final cardStackScrollProgress = ValueNotifier<double>(0);
  final cardStackFrontCardKey = GlobalKey();
  double? _cardStackCollapseThresholdOffset;
  bool _canCollapseCardStack = true;

  Item? get topBarItem => _findItem('cm_top_bar');

  Item? get statementItem => _findItem('unbilled_statement_info_section_v2');

  List<CardModel> get cardModels => items
      .where((item) => item.templateName == 'cm_card_instrument')
      .map(CardModel.fromResponseItem)
      .toList(growable: false);

  List<CreditCardModel> get interactiveCardModels => items
      .where((item) => item.templateName == 'cm_card_instrument')
      .map(
        (item) => CreditCardModel.fromJson(
          item.toJson(),
          actions: cardActions.toList(growable: false),
        ),
      )
      .toList(growable: false);

  Item? _findItem(String templateName) {
    for (final item in items) {
      if (item.templateName == templateName) return item;
    }
    return null;
  }

  void selectTab(int index) {
    selectedTab.value = index;
  }

  void updateCardStackScroll({
    required double scrollOffset,
    required bool frontCardFullyVisible,
  }) {
    if (!frontCardFullyVisible) {
      _canCollapseCardStack = true;
    }

    if (_cardStackCollapseThresholdOffset != null &&
        scrollOffset < _cardStackCollapseThresholdOffset!) {
      _cardStackCollapseThresholdOffset = null;
      _canCollapseCardStack = false;
    } else if (_cardStackCollapseThresholdOffset == null &&
        _canCollapseCardStack &&
        scrollOffset > 0 &&
        frontCardFullyVisible) {
      _cardStackCollapseThresholdOffset = scrollOffset;
      _canCollapseCardStack = false;
    }

    final progress = _cardStackCollapseThresholdOffset == null ? 0.0 : 1.0;
    if ((progress - cardStackScrollProgress.value).abs() >= 0.005) {
      cardStackScrollProgress.value = progress;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchHomeData();
  }

  Future<void> fetchHomeData() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final response = await _homeService.fetchHomeData();
      items.assignAll(response.items);
      cardActions.assignAll(response.cardActions);
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    cardStackScrollProgress.dispose();
    super.onClose();
  }
}
