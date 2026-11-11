import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_hive/features/home/models/card_action_model.dart';
import 'package:job_hive/features/home/models/credit_card_model.dart';
import 'package:job_hive/features/home/views/widget/card_details_sheet.dart';
import 'package:job_hive/features/home/views/widget/card_widget.dart';

class _UpwardVerticalDragGestureRecognizer
    extends VerticalDragGestureRecognizer {
  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent && event.delta.dy > 0) {
      resolve(GestureDisposition.rejected);
      return;
    }
    super.handleEvent(event);
  }
}

class CreditCardItem extends StatefulWidget {
  const CreditCardItem({
    required this.card,
    this.pendingActionSource,
    this.pendingActionProgressSource,
    this.onAction,
    super.key,
  });

  final CreditCardModel card;
  final CreditCardModel? pendingActionSource;
  final ValueListenable<double>? pendingActionProgressSource;
  final ValueChanged<CardActionModel>? onAction;

  @override
  State<CreditCardItem> createState() => _CreditCardItemState();
}

class _CreditCardItemState extends State<CreditCardItem>
    with SingleTickerProviderStateMixin {
  static const _pendingActionHideDelay = Duration(milliseconds: 900);
  static const _spring = SpringDescription(
    mass: 1,
    stiffness: 145,
    damping: 18,
  );

  late final AnimationController _slideController;
  double _dragStartProgress = 0;
  double _dragDistanceX = 0;
  double _verticalDragDistance = 0;
  double _cardWidth = 0;
  double _actionRevealProgress = 0;
  bool _isOpen = false;
  bool _detailsOpening = false;
  bool _pendingActionVisible = true;
  Timer? _pendingActionHideTimer;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController.unbounded(vsync: this);
    _slideController.addListener(_handleSwipeProgressChanged);
  }

  @override
  void dispose() {
    _pendingActionHideTimer?.cancel();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _cardWidth = constraints.maxWidth;
        final cardHeight = (_cardWidth - 40.w) / 1.75 + 46.h;

        return TapRegion(
          onTapOutside: (_) => _close(),
          child: RawGestureDetector(
            gestures: {
              _UpwardVerticalDragGestureRecognizer:
                  GestureRecognizerFactoryWithHandlers<
                    _UpwardVerticalDragGestureRecognizer
                  >(_UpwardVerticalDragGestureRecognizer.new, (recognizer) {
                    recognizer.onStart = (_) {
                      _verticalDragDistance = 0;
                      _detailsOpening = false;
                    };
                    recognizer.onUpdate = (details) {
                      _verticalDragDistance += details.delta.dy;
                      if (!_detailsOpening && _verticalDragDistance <= -80) {
                        _detailsOpening = true;
                        _openDetails();
                      }
                    };
                    recognizer.onEnd = (details) {
                      final velocity = details.velocity.pixelsPerSecond.dy;
                      if (!_detailsOpening &&
                          (_verticalDragDistance <= -80 || velocity <= -650)) {
                        _detailsOpening = true;
                        _openDetails();
                      }
                    };
                  }),
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onLongPress: () => _openDetails(showBack: true),
              onTap: _toggle,
              onHorizontalDragStart: (_) {
                _slideController.stop();
                _dragStartProgress = _progress;
                _dragDistanceX = 0;
              },
              onHorizontalDragUpdate: _handleHorizontalDrag,
              onHorizontalDragEnd: _handleHorizontalDragEnd,
              child: SizedBox(
                width: double.infinity,
                height: cardHeight,
                child: AnimatedBuilder(
                  animation: _slideController,
                  builder: (context, child) {
                    final progress = _progress;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: 0,
                          bottom: 0,
                          right: 0,
                          width: _cardWidth * 0.62,
                          child: _buildActionGrid(progress),
                        ),
                        Positioned.fill(
                          child: ValueListenableBuilder<double>(
                            valueListenable:
                                widget.pendingActionProgressSource ??
                                const _ConstantDoubleListenable(0),
                            builder: (context, pendingActionProgress, child) {
                              return Hero(
                                tag: 'credit-card-${widget.card.id}',
                                flightShuttleBuilder: _cardFlightShuttle,
                                child: CardWidget(
                                  card: widget.card.toCardModel(),
                                  horizontalPadding: 20,
                                  showPendingAction:
                                      _pendingActionVisible &&
                                      (widget.pendingActionSource != null ||
                                          widget.card.pendingActionLabel !=
                                              null),
                                  perspectiveProgress: progress,
                                  horizontalOffset:
                                      -_cardWidth * 0.53 * progress,
                                  pendingActionSource: widget
                                      .pendingActionSource
                                      ?.toCardModel(),
                                  pendingActionProgress: pendingActionProgress,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double get _progress => _slideController.value.clamp(0.0, 1.0);

  void _handleSwipeProgressChanged() {
    if (_progress <= 0.02) {
      _actionRevealProgress = 0;
      _pendingActionHideTimer?.cancel();
      _pendingActionHideTimer = null;
      if (!_pendingActionVisible) {
        setState(() => _pendingActionVisible = true);
      }
      return;
    }

    if (_progress > _actionRevealProgress) {
      _actionRevealProgress = _progress;
    }

    if (!_pendingActionVisible || _pendingActionHideTimer != null) return;
    _pendingActionHideTimer = Timer(_pendingActionHideDelay, () {
      _pendingActionHideTimer = null;
      if (!mounted || _progress <= 0.02) return;
      setState(() => _pendingActionVisible = false);
    });
  }

  Widget _buildActionGrid(double progress) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: widget.card.actions.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 0,
          crossAxisSpacing: 4,
          childAspectRatio: 1.45,
        ),
        itemBuilder: (context, index) {
          final action = widget.card.actions[index];
          final isRevealing = progress >= _actionRevealProgress;
          final revealStart = 0.48 + (index * 0.045);
          final revealProgress = ((_actionRevealProgress - revealStart) / 0.3)
              .clamp(0.0, 1.0);
          final showShimmer =
              isRevealing && progress >= 0.34 && progress < 0.68;

          return InkWell(
            onTap: () => _handleAction(action),
            borderRadius: BorderRadius.circular(10),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  width: 35.w,
                  height: 35.w,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (showShimmer)
                        _ShimmerCircle(
                          progress: _actionRevealProgress,
                          color: _themeColor,
                        ),
                      Opacity(
                        opacity: revealProgress,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE8E8E8)),
                          ),
                          child: Icon(
                            _iconFor(action.icon),
                            size: 20.w,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 0.h),
                SizedBox(
                  height: 20.h,
                  child: Opacity(
                    opacity: revealProgress,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(
                        width: 88.w,
                        child: Text(
                          action.label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9.sp,
                            height: 1.05,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color get _themeColor {
    final value = widget.card.themeColor.replaceFirst('#', '');
    final parsed = int.tryParse(value, radix: 16) ?? 0xB00050;
    return Color(value.length <= 6 ? 0xFF000000 | parsed : parsed);
  }

  IconData _iconFor(String name) {
    return switch (name) {
      'check_circle' => Icons.check_circle_outline,
      'receipt_long' => Icons.receipt_long,
      'history' => Icons.history,
      'local_offer' => Icons.local_offer_outlined,
      'tune' => Icons.tune,
      'manage_search' => Icons.manage_search,
      _ => Icons.credit_card,
    };
  }

  void _handleHorizontalDrag(DragUpdateDetails details) {
    if (_cardWidth == 0) return;
    _dragDistanceX += details.delta.dx;
    _slideController.value = (_dragStartProgress - _dragDistanceX / _cardWidth)
        .clamp(0.0, 1.0);
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    final velocity = -details.velocity.pixelsPerSecond.dx / _cardWidth;
    final shouldOpen = _progress >= 0.32 || velocity > 0.7;
    _settle(open: shouldOpen, velocity: velocity);
  }

  void _toggle() => _settle(open: !_isOpen);

  void _close() => _settle(open: false);

  void _settle({required bool open, double velocity = 0}) {
    _isOpen = open;
    _slideController.animateWith(
      SpringSimulation(_spring, _slideController.value, open ? 1 : 0, velocity),
    );
  }

  void _handleAction(CardActionModel action) {
    if (action.action == 'view_details' || action.action == 'payment_history') {
      _openDetails();
    } else {
      widget.onAction?.call(action);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(action.label)));
    }
  }

  void _openDetails({bool showBack = false}) {
    _close();
    Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierLabel: MaterialLocalizations.of(
          context,
        ).modalBarrierDismissLabel,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 900),
        reverseTransitionDuration: const Duration(milliseconds: 900),
        pageBuilder: (context, animation, secondaryAnimation) =>
            CardDetailsSheet(
              card: widget.card,
              onAction: _handleAction,
              showBack: showBack,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

Widget _cardFlightShuttle(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  final heroContext = flightDirection == HeroFlightDirection.push
      ? toHeroContext
      : fromHeroContext;
  final hero = heroContext.widget as Hero;

  return AnimatedBuilder(
    animation: animation,
    child: hero.child,
    builder: (context, child) {
      final progress = Curves.easeInOutCubic.transform(animation.value);
      final depthProgress = math.sin(progress * math.pi);
      final transform = Matrix4.identity()
        ..setEntry(3, 2, 0.0018)
        ..translate(0.0, -14.0 * depthProgress, -10.0 * depthProgress)
        ..rotateX(-0.34 * depthProgress);

      return Transform(
        alignment: Alignment.center,
        transform: transform,
        child: child,
      );
    },
  );
}

class _ShimmerCircle extends StatelessWidget {
  const _ShimmerCircle({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final shimmerPosition = ((progress - 0.34) / 0.34).clamp(0.0, 1.0);
    final shift = -1.0 + (2 * shimmerPosition);

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment(shift - 0.8, -0.4),
          end: Alignment(shift + 0.8, 0.4),
          colors: [
            color.withValues(alpha: 0.12),
            Colors.white,
            color.withValues(alpha: 0.2),
          ],
        ),
      ),
    );
  }
}

class _ConstantDoubleListenable implements ValueListenable<double> {
  const _ConstantDoubleListenable(this.value);

  @override
  final double value;

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}
}
