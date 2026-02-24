import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:my_bandar/main.dart';
import 'package:my_bandar/providers/app_provider.dart';

void main() {
  testWidgets('App launches and shows login screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: const MyBandarApp(),
      ),
    );

    expect(find.text('MyBandar'), findsOneWidget);
    expect(find.text('Log In with Google'), findsOneWidget);
  });
}
