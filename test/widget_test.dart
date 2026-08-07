import 'package:flutter_test/flutter_test.dart';
import 'package:story_hub/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const StoryHubApp());
    expect(find.text('StoryHub'), findsWidgets);
  });
}
