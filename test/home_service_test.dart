import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_hive/features/home/models/card_action_model.dart';
import 'package:job_hive/features/home/models/card_model.dart';
import 'package:job_hive/features/home/models/credit_card_model.dart';
import 'package:job_hive/features/home/service/home_service.dart';
import 'package:job_hive/features/home/views/widget/card_widget.dart';
import 'package:job_hive/features/home/views/widget/credit_card_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads the header and statement data from the mock response', () async {
    final response = await HomeService().fetchHomeData();
    final topBar = response.items.singleWhere(
      (item) => item.templateName == 'cm_top_bar',
    );
    final statementSection = response.items.singleWhere(
      (item) => item.templateName == 'unbilled_statement_info_section_v2',
    );
    final primaryCardResponse = response.items.singleWhere(
      (item) =>
          item.templateName == 'cm_card_instrument' &&
          item.templateProperties.body.text3 == '•• 1234',
    );
    final primaryCard = CardModel.fromResponseItem(primaryCardResponse);
    final hdfcResponse = response.items.singleWhere(
      (item) =>
          item.templateName == 'cm_card_instrument' &&
          item.templateProperties.body.text3 == '•• 5501',
    );
    final hdfcCard = CreditCardModel.fromJson(
      hdfcResponse.toJson(),
      actions: response.cardActions,
    );

    expect(
      topBar.templateProperties.body.cta2?.asset?.url,
      'https://assets.dreamplug.in/octapaul/heartbeat/a170fe5083de11ef852e31eafd837164.png',
    );
    expect(
      topBar.templateProperties.body.cta3?.asset?.url,
      'https://assets.dreamplug.in/octapaul/heartbeat/ca90a47083de11ef852e31eafd837164.png',
    );
    expect(
      statementSection.templateProperties.body.statement?.text2,
      '₹50,000.00',
    );
    expect(
      statementSection.templateProperties.body.asset1?.url,
      'https://assets.dreamplug.in/octapaul/heartbeat/cd437f201da811f1a9b1e5989777e21c.png',
    );
    expect(primaryCard.plainPendingActionLabel, '2 pending actions');
    expect(primaryCard.plainViewDetailsLabel, 'View details');
    expect(response.cardActions, hasLength(6));
    expect(response.cardActions.first.label, 'Mark as paid');
    expect(hdfcCard.bankName, 'HDFC BANK');
    expect(hdfcCard.cardNumber, '•• 5501');
    expect(hdfcCard.actions.last.action, 'view_details');
  });

  testWidgets('left swipe slides the card open to reveal actions', (
    tester,
  ) async {
    final card = CreditCardModel(
      id: 'test-card',
      bankName: 'TEST BANK',
      cardholderName: 'CARDHOLDER',
      cardNumber: '•• 1234',
      dueAmount: '₹1,000.00',
      dueDate: 'DUE ON 18 SEP',
      backgroundImageUrl: '',
      cardArtUrl: '',
      themeColor: '#B00050',
      pendingActionLabel: '2 pending actions',
      actions: [
        for (var index = 0; index < 6; index++)
          CardActionModel(
            id: 'action-$index',
            label: 'Action $index',
            icon: 'history',
            action: 'action-$index',
          ),
      ],
      detailRows: const [],
      history: const [],
    );

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(width: 360, child: CreditCardItem(card: card)),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final cardFaceFinder = find
        .descendant(
          of: find.byType(CardWidget),
          matching: find.byType(AspectRatio),
        )
        .first;
    final initialRect = tester.getRect(cardFaceFinder);

    await tester.timedDrag(
      find.byType(CreditCardItem),
      const Offset(-260, 0),
      const Duration(milliseconds: 100),
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('2 pending actions'), findsOneWidget);

    final pendingActionFinder = find.text('2 pending actions');
    final pendingActionPosition = tester.getCenter(pendingActionFinder);
    final cardRect = tester.getRect(cardFaceFinder);
    final closingGesture = await tester.startGesture(
      Offset(
        cardRect.left + (cardRect.width * 0.7),
        cardRect.top + (cardRect.height * 0.5),
      ),
    );
    await closingGesture.moveBy(const Offset(140, 0));
    await tester.pump();
    expect(tester.getCenter(pendingActionFinder), pendingActionPosition);
    await closingGesture.up();
    await tester.pumpAndSettle();

    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.getSize(find.byType(AnimatedSize)).height, 0);

    final openRect = tester.getRect(cardFaceFinder);
    expect(openRect.left, lessThan(initialRect.left - 100));
    expect(find.text('Action 0'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Icon && widget.color == Colors.black,
      ),
      findsWidgets,
    );

    final actionTextFinder = find.text('Action 0');
    final actionOpacityFinder = find.ancestor(
      of: actionTextFinder,
      matching: find.byType(Opacity),
    );
    final initialActionOpacity = tester
        .widget<Opacity>(actionOpacityFinder.first)
        .opacity;
    final initialActionPosition = tester.getCenter(actionTextFinder);
    final actionCardRect = tester.getRect(cardFaceFinder);
    final gesture = await tester.startGesture(
      Offset(
        actionCardRect.left + (actionCardRect.width * 0.7),
        actionCardRect.top + (actionCardRect.height * 0.5),
      ),
    );
    await gesture.moveBy(const Offset(140, 0));
    await tester.pump();

    expect(
      tester.widget<Opacity>(actionOpacityFinder.first).opacity,
      initialActionOpacity,
    );
    expect(tester.getCenter(actionTextFinder), initialActionPosition);

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('upward swipe opens card details from the top', (tester) async {
    final card = CreditCardModel(
      id: 'details-card',
      bankName: 'TEST BANK',
      cardholderName: 'CARDHOLDER',
      cardNumber: '•• 4321',
      dueAmount: '₹1,000.00',
      dueDate: 'DUE ON 18 SEP',
      backgroundImageUrl: '',
      cardArtUrl: '',
      themeColor: '#343434',
      actions: const [
        CardActionModel(
          id: 'mark_paid',
          label: 'Mark as paid',
          icon: 'check_circle',
          action: 'mark_paid',
        ),
        CardActionModel(
          id: 'payment_history',
          label: 'Payment history',
          icon: 'history',
          action: 'payment_history',
        ),
      ],
      detailRows: const [
        {'label': 'Card number', 'value': '•• 4321'},
      ],
      history: const [
        {
          'title': 'Statement generated',
          'subtitle': 'Due on 18 Sep',
          'amount': '₹1,000.00',
        },
      ],
    );

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(width: 360, child: CreditCardItem(card: card)),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.timedDrag(
      find.byType(CreditCardItem),
      const Offset(0, -140),
      const Duration(milliseconds: 180),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DraggableScrollableSheet), findsOneWidget);
    final sheetRect = tester.getRect(find.byType(DraggableScrollableSheet));
    expect(sheetRect.top, 0);
    final viewportHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    expect(sheetRect.bottom, lessThan(viewportHeight));
    expect(find.text('Mark as paid'), findsWidgets);
    await tester.drag(find.byType(ListView).last, const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('TEST BANK'), findsOneWidget);
    expect(find.text('Card number'), findsOneWidget);
    await tester.drag(find.byType(ListView).last, const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Statement generated'), findsOneWidget);
  });
}
