import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet_mvp/main.dart';

void main() {
  testWidgets('renders wallet app', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: WalletApp()));

    expect(find.text('Wallet MVP'), findsNothing);
  });
}
