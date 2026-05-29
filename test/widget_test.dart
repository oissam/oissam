import 'package:flutter_test/flutter_test.dart';
import 'package:internal_exam_planner/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // App builds without errors
    await tester.pumpWidget(const InternalExamPlannerApp());
    expect(find.byType(InternalExamPlannerApp), findsOneWidget);
  });
}
