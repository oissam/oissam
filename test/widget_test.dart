import 'package:flutter_test/flutter_test.dart';
import 'package:internal_exam_planner/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(InternalExamPlannerApp());
    expect(find.byType(InternalExamPlannerApp), findsOneWidget);
  });
}
