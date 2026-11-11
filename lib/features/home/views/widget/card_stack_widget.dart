import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_hive/features/home/models/card_model.dart';
import 'package:job_hive/features/home/views/widget/card_widget.dart';

class CardStackWidget extends StatelessWidget {
  const CardStackWidget({
    required this.cardsBackToFront,
    required this.scrollProgress,
    required this.pendingActionSource,
    this.frontCardKey,
    super.key,
  });

  static const _maxVisibleCards = 4;
  static const _cardAspectRatio = 1.75;
  static const _horizontalInsetStep = 12.0;
  static const _topOffsetFactors = [0.0, 0.05, 0.14, 0.49];

  final List<CardModel> cardsBackToFront;
  final ValueListenable<double> scrollProgress;
  final CardModel pendingActionSource;
  final GlobalKey? frontCardKey;

  @override
  Widget build(BuildContext context) {
    if (cardsBackToFront.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final visibleCards = cardsBackToFront
            .take(_maxVisibleCards)
            .toList(growable: false);
        final cardWidth = constraints.maxWidth - 30.w;
        final cardHeight = cardWidth / _cardAspectRatio;
        final frontIndex = visibleCards.length - 1;
        final frontCardTop = cardHeight * _topOffsetFactors[frontIndex];
        final actionHeight = 36.h;

        return SizedBox(
          width: double.infinity,
          height: cardHeight + frontCardTop + actionHeight,
          child: ValueListenableBuilder<double>(
            valueListenable: scrollProgress,
            builder: (context, rawProgress, child) {
              final progress = rawProgress.clamp(0.0, 1.0);

              return Stack(
                children: List.generate(visibleCards.length, (index) {
                  final isFrontCard = index == frontIndex;
                  final expandedTop = cardHeight * _topOffsetFactors[index];
                  final top = isFrontCard
                      ? frontCardTop
                      : expandedTop + (frontCardTop - expandedTop) * progress;
                  final opacity = isFrontCard ? 1.0 : 1.0 - progress;
                  final scale = isFrontCard ? 1.0 : 1.0 - (0.04 * progress);

                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    top: top,
                    left: 0,
                    right: 0,
                    child: AnimatedScale(
                      scale: scale,
                      alignment: Alignment.topCenter,
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      child: AnimatedOpacity(
                        opacity: opacity,
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                        child: CardWidget(
                          card: visibleCards[index],
                          cardFrameKey: isFrontCard ? frontCardKey : null,
                          showPendingAction: isFrontCard,
                          pendingActionSource: isFrontCard
                              ? pendingActionSource
                              : null,
                          pendingActionProgress: 0,
                          horizontalPadding:
                              15 +
                              (visibleCards.length - index - 1) *
                                  _horizontalInsetStep,
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        );
      },
    );
  }
}
