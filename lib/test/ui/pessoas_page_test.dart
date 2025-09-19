import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exemplo/data/fake_pessoas_repository.dart';
import 'package:exemplo/repositories/i_pessoas_repository.dart';
import 'package:exemplo/pages/pessoas_page.dart';

void main() {
  testWidgets('Mostra mensagem se não houver pessoas', (tester) async {
    final repo = FakePessoasRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: PessoasPage(
          repo: repo,
        ), // precisa ajustar PessoasPage para aceitar repo
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma pessoa cadastrada.'), findsOneWidget);
  });

  testWidgets('Adiciona pessoa e exibe na lista', (tester) async {
    final repo = FakePessoasRepository();
    await tester.pumpWidget(MaterialApp(home: PessoasPage(repo: repo)));
    await tester.pumpAndSettle();

    // preencher campos
    await tester.enterText(find.bySemanticsLabel('Nome'), 'Carlos');
    await tester.enterText(find.bySemanticsLabel('Idade'), '42');

    // clicar no botão adicionar
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    expect(find.textContaining('Carlos'), findsOneWidget);
  });
}
