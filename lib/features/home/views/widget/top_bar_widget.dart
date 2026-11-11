import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_hive/features/home/models/cred_model.dart';

class TopBarWidget extends StatelessWidget {
  const TopBarWidget({
    required this.topBarItem,
    required this.statementItem,
    required this.selectedTab,
    required this.onTabSelected,
    super.key,
  });

  final Item topBarItem;
  final Item statementItem;
  final int selectedTab;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final topBarBody = topBarItem.templateProperties.body;
    final statementBody = statementItem.templateProperties.body;
    final statement = statementBody.statement!;
    final unbilled = statementBody.unbilled!;
    final isRecentSpendsSelected = selectedTab == 1;
    final heading = isRecentSpendsSelected
        ? unbilled.text3
        : statement.text1 ?? '';
    final amount = isRecentSpendsSelected ? unbilled.text2 : statement.text2;
    final actionLabel = isRecentSpendsSelected
        ? unbilled.cta2.title
        : statement.cta2?.title;
    final backgroundUrl = statementBody.asset1?.url;
    final offer = statementItem.templateProperties.childList.isEmpty
        ? null
        : statementItem.templateProperties.childList.first;
    final offerText =
        offer == null || offer.templateProperties.body.flipperConfig.isEmpty
        ? null
        : offer.templateProperties.body.flipperConfig.first.text1.replaceAll(
            RegExp(r'<[^>]*>'),
            '',
          );

    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (backgroundUrl != null && backgroundUrl.isNotEmpty)
            Image.network(
              backgroundUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const ColoredBox(color: Color(0xFFF7F5F0)),
            )
          else
            const ColoredBox(color: Color(0xFFF7F5F0)),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 18, 16.w, 14),
            child: Column(
              children: [
                Row(
                  children: [
                    _AssetIcon(url: topBarBody.cta2?.asset?.url),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Container(
                        height: 46,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFEFEF),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Row(
                          children: [
                            _TabButton(
                              label: statement.text3 ?? 'TOTAL DUE',
                              selected: selectedTab == 0,
                              badge: statement.dueCount?.toString(),
                              onTap: () => onTabSelected(0),
                            ),
                            _TabButton(
                              label: unbilled.text1,
                              selected: selectedTab == 1,
                              onTap: () => onTabSelected(1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    _AssetIcon(url: topBarBody.cta3?.asset?.url),
                  ],
                ),
                const SizedBox(height: 56),
                Text(
                  heading,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF888888),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      amount,
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'serif',
                        fontSize: 37.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, size: 24),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 30.w),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(actionLabel ?? 'Pay bill'),
                  ),
                ),
              ],
            ),
          ),

          if (offer != null && offerText != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 48,
                margin: EdgeInsets.symmetric(horizontal: 60),
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    _AssetIcon(
                      url: offer.templateProperties.body.asset.url,
                      size: 20,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        offerText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF6A3C6A),
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.black54),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AssetIcon extends StatelessWidget {
  const _AssetIcon({required this.url, this.size = 28});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return SizedBox(width: size, height: size);

    return Image.network(
      url!,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          SizedBox(width: size, height: size),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final String label;
  final bool selected;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              boxShadow: selected
                  ? const [
                      BoxShadow(
                        color: Color(0x18000000),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? Colors.black : Colors.grey,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
                if (badge != null && badge != '0') ...[
                  SizedBox(width: 5.w),
                  Container(
                    width: 16,
                    height: 16,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE85C4A),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
