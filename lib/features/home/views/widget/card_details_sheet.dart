import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:job_hive/features/home/controllers/card_details_controller.dart';
import 'package:job_hive/features/home/models/card_action_model.dart';
import 'package:job_hive/features/home/models/credit_card_model.dart';
import 'package:job_hive/features/home/views/widget/card_widget.dart';

class CardDetailsSheet extends StatefulWidget {
  const CardDetailsSheet({
    required this.card,
    this.onAction,
    this.showBack = false,
    super.key,
  });

  final CreditCardModel card;
  final ValueChanged<CardActionModel>? onAction;
  final bool showBack;

  @override
  State<CardDetailsSheet> createState() => _CardDetailsSheetState();
}

class _CardDetailsSheetState extends State<CardDetailsSheet> {
  final _historySectionKey = GlobalKey();
  late bool _showBack = widget.showBack;

  @override
  Widget build(BuildContext context) {
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.68;

    return GetBuilder<CardDetailsController>(
      init: CardDetailsController(card: widget.card),
      builder: (controller) => Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          height: sheetHeight,
          width: double.infinity,
          child: DraggableScrollableSheet(
            initialChildSize: 1,
            minChildSize: 0.78,
            maxChildSize: 1,
            snap: true,
            snapSizes: const [1],
            builder: (context, scrollController) => Material(
              color: const Color(0xFFFFFFFF),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Hero(
                    tag: 'credit-card-${controller.card.id}',
                    child: Transform.translate(
                      offset: Offset(
                        0,
                        -(MediaQuery.paddingOf(context).top + 22.h),
                      ),
                      child: Align(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: sheetHeight * 0.975,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: GestureDetector(
                                onLongPress: _toggleBack,
                                child: CardWidget(
                                  card: controller.card.toCardModel(),
                                  horizontalPadding: 0,
                                  showPendingAction: false,
                                  showBack: _showBack,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
                    child: Column(
                      children: [
                        // SizedBox(height: 18.h),
                        if (controller.quickActions.isNotEmpty)
                          _QuickActions(
                            actions: controller.quickActions,
                            controller: controller,
                            onAction: _handleAction,
                            onHistoryTap: _scrollToHistory,
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 28.h),
                      children: [
                        const _DottedDivider(),
                        if (controller.activityRows.isNotEmpty)
                          _ActivitySection(
                            date: controller.activityDate,
                            rows: controller.activityRows,
                            controller: controller,
                          )
                        else ...[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              controller.card.bankName,
                              style: TextStyle(
                                color: controller.themeColor,
                                fontSize: 19.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          if (controller.detailRows.isEmpty)
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text('No card details available.'),
                            )
                          else
                            for (final row in controller.detailRows)
                              _DetailRow(
                                label: row['label'] ?? '',
                                value: row['value'] ?? '',
                              ),
                          SizedBox(height: 18.h),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Payment history',
                              key: _historySectionKey,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          if (controller.history.isEmpty)
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text('No recent payment activity.'),
                            )
                          else
                            for (final entry in controller.history)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  Icons.receipt_long,
                                  color: controller.themeColor,
                                ),
                                title: Text(entry['title'] ?? ''),
                                subtitle: Text(entry['subtitle'] ?? ''),
                                trailing: Text(entry['amount'] ?? ''),
                              ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleBack() {
    setState(() => _showBack = !_showBack);
  }

  void _handleAction(CardDetailsController controller, CardActionModel action) {
    if (action.action == 'payment_history') {
      _scrollToHistory();
      return;
    }

    widget.onAction?.call(action);
  }

  void _scrollToHistory() {
    final historyContext = _historySectionKey.currentContext;
    if (historyContext == null) return;
    Scrollable.ensureVisible(
      historyContext,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.actions,
    required this.controller,
    required this.onAction,
    required this.onHistoryTap,
  });

  final List<CardActionModel> actions;
  final CardDetailsController controller;
  final void Function(CardDetailsController, CardActionModel) onAction;
  final VoidCallback onHistoryTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54.h,
      child: Row(
        children: [
          for (var index = 0; index < actions.length; index++) ...[
            if (index > 0)
              const VerticalDivider(
                width: 1,
                indent: 4,
                endIndent: 4,
                color: Color(0xFFE7E7E7),
              ),
            Expanded(
              child: InkWell(
                onTap: actions[index].action == 'payment_history'
                    ? onHistoryTap
                    : () => onAction(controller, actions[index]),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      controller.iconForAction(actions[index].icon),
                      size: 20.w,
                      color: Colors.black,
                    ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        actions[index].label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.sp),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DottedDivider extends StatelessWidget {
  const _DottedDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 24,
      width: double.infinity,
      child: CustomPaint(painter: _DottedDividerPainter()),
    );
  }
}

class _DottedDividerPainter extends CustomPainter {
  const _DottedDividerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 1;
    final y = size.height / 2;

    for (var x = 0.0; x < size.width; x += 6) {
      canvas.drawRect(Rect.fromLTWH(x, y, 2, 1), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DottedDividerPainter oldDelegate) => false;
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 9.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF858585)),
            ),
          ),
          SizedBox(width: 12.w),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivitySection extends StatelessWidget {
  const _ActivitySection({
    required this.date,
    required this.rows,
    required this.controller,
  });

  final String date;
  final List<Map<String, String>> rows;
  final CardDetailsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date,
          style: TextStyle(
            color: const Color(0xFF9B9B9B),
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.2,
          ),
        ),
        SizedBox(height: 22.h),
        for (final row in rows)
          Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: Row(
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Icon(
                    controller.iconForAction(row['icon'] ?? ''),
                    color: Colors.black87,
                    size: 24.w,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        row['label'] ?? '',
                        style: TextStyle(
                          color: const Color(0xFF9B9B9B),
                          fontSize: 13.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        row['value'] ?? '',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, size: 24.w),
              ],
            ),
          ),
      ],
    );
  }
}
