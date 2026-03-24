import 'package:flutter_test/flutter_test.dart';

import 'package:eat_what/main.dart';

void main() {
  testWidgets('App loads and shows home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const EatWhatApp());

    expect(find.text('吃啥'), findsOneWidget);
  });
}
