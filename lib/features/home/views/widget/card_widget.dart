import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_hive/features/home/models/card_model.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({
    required this.card,
    this.horizontalPadding = 20,
    this.showPendingAction = false,
    this.pendingActionProgress = 0,
    this.perspectiveProgress = 0,
    this.horizontalOffset = 0,
    this.showBack = false,
    this.cardFrameKey,
    this.pendingActionSource,
    this.onPayNow,
    super.key,
  });

  final CardModel card;
  final double horizontalPadding;
  final bool showPendingAction;
  final double pendingActionProgress;
  final double perspectiveProgress;
  final double horizontalOffset;
  final bool showBack;
  final GlobalKey? cardFrameKey;
  final CardModel? pendingActionSource;
  final VoidCallback? onPayNow;

  @override
  Widget build(BuildContext context) {
    final pendingProgress = pendingActionProgress.clamp(0.0, 1.0);
    final perspective = perspectiveProgress.clamp(0.0, 1.0);
    final actionCard = pendingActionSource ?? card;
    final hasViewDetails =
        actionCard.viewDetailsLabel != null &&
        actionCard.viewDetailsLabel!.isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.translate(
            offset: Offset(horizontalOffset, 0),
            child: AspectRatio(
              key: cardFrameKey,
              aspectRatio: 1.75,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final height = constraints.maxHeight;

                  final borderRadius = BorderRadius.circular(width * 0.035);

                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.009)
                      ..rotateY(-0.1 * perspective)
                      ..setEntry(1, 0, 0.04 * perspective),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: borderRadius,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: 0.22 * perspective,
                            ),
                            blurRadius: 28 * perspective,
                            offset: Offset(10 * perspective, 18 * perspective),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: borderRadius,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (showBack)
                              _CardBack(card: card)
                            else ...[
                              if (card.backgroundImageUrl.isNotEmpty)
                                Image.network(
                                  card.backgroundImageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const ColoredBox(
                                        color: Color(0xFFB00050),
                                      ),
                                )
                              else
                                const ColoredBox(color: Color(0xFFB00050)),
                              if (card.cardArtUrl.isNotEmpty)
                                Positioned(
                                  left: width * 0.07,
                                  top: height * 0.11,
                                  width: width * 0.34,
                                  height: height * 0.16,
                                  child: Image.network(
                                    card.cardArtUrl,
                                    fit: BoxFit.contain,
                                    alignment: Alignment.centerLeft,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const SizedBox.shrink(),
                                  ),
                                ),
                              Positioned(
                                left: width * 0.075,
                                top: height * 0.37,
                                child: Text(
                                  card.cardNumber,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: width * 0.035,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: width * 0.004,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: height * 0.12,
                                right: width * 0.07,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      card.amount,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: width * 0.04,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: height * 0.025),
                                    Text(
                                      card.dueDate,
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: width * 0.03,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: width * 0.002,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                left: width * 0.075,
                                bottom: height * 0.11,
                                child: Text(
                                  card.cardholderName.toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: width * 0.034,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: width * 0.004,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: width * 0.07,
                                bottom: height * 0.105,
                                width: width * 0.27,
                                height: height * 0.17,
                                child: ElevatedButton(
                                  onPressed: onPayNow,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    disabledBackgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    disabledForegroundColor: Colors.black,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        width * 0.008,
                                      ),
                                    ),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      card.payButtonLabel,
                                      style: TextStyle(
                                        fontSize: width * 0.034,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (actionCard.pendingActionLabel != null &&
              actionCard.pendingActionLabel!.isNotEmpty)
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: showPendingAction ? 1 : 0,
                  child: IgnorePointer(
                    ignoring: !showPendingAction,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 240),
                      opacity: showPendingAction ? 1 : 0,
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeInOutCubic,
                        offset: showPendingAction
                            ? Offset.zero
                            : const Offset(0, -0.2),
                        child: Padding(
                          padding: EdgeInsets.only(top: 10.h),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: null,
                              borderRadius: BorderRadius.circular(24),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 280),
                                curve: Curves.easeOutCubic,
                                width: 160.w - (30.w * pendingProgress),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w - (4.w * pendingProgress),
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: const Color(0xFFE8E8E8),
                                  ),
                                ),
                                child: ClipRect(
                                  child: SizedBox(
                                    height: 22.h,
                                    child: Stack(
                                      clipBehavior: Clip.hardEdge,
                                      children: [
                                        AnimatedPositioned(
                                          duration: const Duration(
                                            milliseconds: 980,
                                          ),
                                          curve: Curves.easeOutCubic,
                                          top: -22.h * pendingProgress,
                                          left: 0,
                                          right: 0,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                height: 22.h,
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    if (actionCard
                                                            .pendingActionImageUrl
                                                        case final imageUrl?)
                                                      Image.network(
                                                        imageUrl,
                                                        width: 16.w,
                                                        height: 16.w,
                                                        fit: BoxFit.contain,
                                                        errorBuilder:
                                                            (
                                                              context,
                                                              error,
                                                              stackTrace,
                                                            ) =>
                                                                const SizedBox.shrink(),
                                                      ),
                                                    SizedBox(width: 6.w),
                                                    Flexible(
                                                      child: Text(
                                                        actionCard
                                                            .plainPendingActionLabel,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 11.sp,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 4.w),
                                                    Icon(
                                                      Icons.chevron_right,
                                                      size: 16.w,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (hasViewDetails)
                                                SizedBox(
                                                  height: 22.h,
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          actionCard
                                                              .plainViewDetailsLabel,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontSize: 11.sp,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 4.w),
                                                      Icon(
                                                        Icons.chevron_right,
                                                        size: 16.w,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack({required this.card});

  final CardModel card;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (card.backgroundImageUrl.isNotEmpty)
                Image.network(
                  card.backgroundImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const ColoredBox(color: Color(0xFFB00050)),
                )
              else
                const ColoredBox(color: Color(0xFFB00050)),
              if (card.cardArtUrl.isNotEmpty)
                Positioned(
                  left: constraints.maxWidth * 0.07,
                  top: constraints.maxHeight * 0.11,
                  width: constraints.maxWidth * 0.34,
                  height: constraints.maxHeight * 0.16,
                  child: Image.network(
                    card.cardArtUrl,
                    fit: BoxFit.contain,
                    alignment: Alignment.centerLeft,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
