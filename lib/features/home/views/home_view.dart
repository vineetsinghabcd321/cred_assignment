import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:job_hive/features/home/controllers/home_controller.dart';
import 'package:job_hive/features/home/views/widget/card_stack_widget.dart';
import 'package:job_hive/features/home/views/widget/credit_card_item.dart';
import 'package:job_hive/features/home/views/widget/top_bar_widget.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final pinnedHeaderHeight = 300.0;

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.value != null) {
            return Center(child: Text(controller.errorMessage.value!));
          }

          final topBarItem = controller.topBarItem;
          final statementItem = controller.statementItem;
          final cardModels = controller.cardModels;
          final interactiveCardModels = controller.interactiveCardModels;
          final interactiveStackModels = interactiveCardModels
              .skip(1)
              .toList()
              .reversed
              .take(4)
              .toList(growable: false);
          final stackCardModels = cardModels
              .skip(1)
              .toList()
              .reversed
              .take(4)
              .toList(growable: false);
          if (topBarItem == null || statementItem == null) {
            return const Center(child: Text('Home content is unavailable.'));
          }

          return NotificationListener<ScrollNotification>(
            onNotification: (notification) => _handleScrollNotification(
              context,
              notification,
              pinnedHeaderHeight,
            ),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  primary: false,
                  automaticallyImplyLeading: false,
                  toolbarHeight: 0,
                  collapsedHeight: pinnedHeaderHeight,
                  expandedHeight: pinnedHeaderHeight,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  flexibleSpace: TopBarWidget(
                    topBarItem: topBarItem,
                    statementItem: statementItem,
                    selectedTab: controller.selectedTab.value,
                    onTabSelected: controller.selectTab,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      if (cardModels.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        CreditCardItem(
                          card: interactiveCardModels.first,
                          pendingActionProgressSource:
                              controller.cardStackScrollProgress,
                        ),
                        if (cardModels.length > 1) ...[
                          const SizedBox(height: 28),
                          CardStackWidget(
                            cardsBackToFront: stackCardModels,
                            scrollProgress: controller.cardStackScrollProgress,
                            pendingActionSource: cardModels.first,
                            frontCardKey: controller.cardStackFrontCardKey,
                          ),
                          const SizedBox(height: 34),
                        ],
                      ],
                    ],
                  ),
                ),
                if (stackCardModels.length > 1)
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final cardIndex =
                          interactiveStackModels.length - 2 - index;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 34),
                        child: CreditCardItem(
                          card: interactiveStackModels[cardIndex],
                          pendingActionSource: interactiveCardModels.first,
                        ),
                      );
                    }, childCount: interactiveStackModels.length - 1),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  bool _handleScrollNotification(
    BuildContext context,
    ScrollNotification notification,
    double pinnedHeaderHeight,
  ) {
    if (notification.depth != 0 || notification.metrics.axis != Axis.vertical) {
      return false;
    }

    final renderObject = controller.cardStackFrontCardKey.currentContext
        ?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return false;

    final cardTopLeft = renderObject.localToGlobal(Offset.zero);
    final cardRect = cardTopLeft & renderObject.size;
    final mediaQuery = MediaQuery.of(context);
    final pinnedHeaderBottom = mediaQuery.padding.top + pinnedHeaderHeight;
    final viewportBottom = mediaQuery.size.height - mediaQuery.padding.bottom;
    final isFullyVisible =
        cardRect.top >= pinnedHeaderBottom && cardRect.bottom <= viewportBottom;

    controller.updateCardStackScroll(
      scrollOffset: notification.metrics.pixels,
      frontCardFullyVisible: isFullyVisible,
    );
    return false;
  }
}
