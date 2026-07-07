import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/models/friend_request.dart';
import 'package:levelup_alarm/models/user_summary.dart';
import 'package:levelup_alarm/providers/friends_provider.dart';
import 'package:levelup_alarm/screens/friends_screen.dart';
import 'package:levelup_alarm/services/friends_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockFriendsService extends Mock implements FriendsService {}

Widget _buildScreen(FriendsProvider provider) {
  return ChangeNotifierProvider<FriendsProvider>.value(
    value: provider,
    child: const MaterialApp(home: FriendsScreen()),
  );
}

void main() {
  late MockFriendsService mockService;

  setUpAll(() {
    registerFallbackValue(
      const FriendRequest(fromUid: 'fallback-from', fromUsername: 'fallback', toUid: 'fallback-to'),
    );
  });

  setUp(() {
    mockService = MockFriendsService();
    when(() => mockService.loadFriends(any())).thenAnswer((_) async => []);
    when(() => mockService.loadIncomingRequests(any())).thenAnswer((_) async => []);
    when(() => mockService.loadSentRequests(any())).thenAnswer((_) async => []);
  });

  group('FriendsScreen — friends list', () {
    testWidgets('lista los usernames de los amigos', (tester) async {
      when(() => mockService.loadFriends('u1')).thenAnswer(
        (_) async => [
          const UserSummary(uid: 'u2', username: 'misty'),
          const UserSummary(uid: 'u3', username: 'gary'),
        ],
      );
      final provider = FriendsProvider(friendsService: mockService, uid: 'u1');

      await tester.pumpWidget(_buildScreen(provider));
      await tester.pumpAndSettle();

      expect(find.text('misty'), findsOneWidget);
      expect(find.text('gary'), findsOneWidget);
    });

    testWidgets('muestra estado vacío cuando no hay amigos', (tester) async {
      final provider = FriendsProvider(friendsService: mockService, uid: 'u1');

      await tester.pumpWidget(_buildScreen(provider));
      await tester.pumpAndSettle();

      expect(find.textContaining('amigo'), findsWidgets);
    });
  });

  group('FriendsScreen — search', () {
    testWidgets(
        'escribir en la búsqueda y obtener resultados muestra el usuario con botón Agregar; tocarlo llama sendRequest(uid)',
        (tester) async {
      when(() => mockService.searchUsers(any(), excludeUid: any(named: 'excludeUid')))
          .thenAnswer((_) async => [const UserSummary(uid: 'u9', username: 'brock')]);
      when(() => mockService.loadUsername('u1')).thenAnswer((_) async => 'ash');
      when(() => mockService.sendRequest(
            fromUid: any(named: 'fromUid'),
            fromUsername: any(named: 'fromUsername'),
            toUid: any(named: 'toUid'),
            toUsername: any(named: 'toUsername'),
          )).thenAnswer((_) async {});
      final provider = FriendsProvider(friendsService: mockService, uid: 'u1');

      await tester.pumpWidget(_buildScreen(provider));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'brock');
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('brock'), findsWidgets);
      expect(find.text('Agregar'), findsOneWidget);

      await tester.tap(find.text('Agregar'));
      await tester.pumpAndSettle();

      verify(() => mockService.sendRequest(
          fromUid: 'u1', fromUsername: 'ash', toUid: 'u9', toUsername: 'brock')).called(1);

      // Feedback on success: the button must switch to a disabled "Enviada".
      expect(find.text('Agregar'), findsNothing);
      expect(find.text('Enviada'), findsOneWidget);
    });

    testWidgets('si el envío falla se muestra el errorMessage del provider', (tester) async {
      when(() => mockService.searchUsers(any(), excludeUid: any(named: 'excludeUid')))
          .thenAnswer((_) async => [const UserSummary(uid: 'u9', username: 'brock')]);
      when(() => mockService.loadUsername('u1')).thenAnswer((_) async => 'ash');
      when(() => mockService.sendRequest(
            fromUid: any(named: 'fromUid'),
            fromUsername: any(named: 'fromUsername'),
            toUid: any(named: 'toUid'),
            toUsername: any(named: 'toUsername'),
          )).thenThrow(Exception('boom'));
      final provider = FriendsProvider(friendsService: mockService, uid: 'u1');

      await tester.pumpWidget(_buildScreen(provider));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'brock');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Agregar'));
      await tester.pumpAndSettle();

      expect(find.text('No se pudo enviar la solicitud. Intentá de nuevo'), findsOneWidget);
    });
  });

  group('FriendsScreen — incoming requests', () {
    testWidgets(
        'muestra las solicitudes recibidas con Aceptar/Rechazar; tocarlos llama accept(request)/reject(request)',
        (tester) async {
      const request = FriendRequest(fromUid: 'a', fromUsername: 'ash', toUid: 'u1');
      when(() => mockService.loadIncomingRequests('u1')).thenAnswer((_) async => [request]);
      when(() => mockService.loadUsername('u1')).thenAnswer((_) async => 'misty');
      when(() => mockService.acceptRequest(
            request: any(named: 'request'),
            myUsername: any(named: 'myUsername'),
          )).thenAnswer((_) async {});
      when(() => mockService.rejectRequest(any())).thenAnswer((_) async {});
      final provider = FriendsProvider(friendsService: mockService, uid: 'u1');

      await tester.pumpWidget(_buildScreen(provider));
      await tester.pumpAndSettle();

      expect(find.text('ash'), findsOneWidget);
      expect(find.text('Aceptar'), findsOneWidget);
      expect(find.text('Rechazar'), findsOneWidget);

      await tester.tap(find.text('Aceptar'));
      await tester.pumpAndSettle();

      verify(() => mockService.acceptRequest(request: request, myUsername: 'misty')).called(1);
    });

    testWidgets('tocar Rechazar llama reject(request)', (tester) async {
      const request = FriendRequest(fromUid: 'a', fromUsername: 'ash', toUid: 'u1');
      when(() => mockService.loadIncomingRequests('u1')).thenAnswer((_) async => [request]);
      when(() => mockService.rejectRequest(any())).thenAnswer((_) async {});
      final provider = FriendsProvider(friendsService: mockService, uid: 'u1');

      await tester.pumpWidget(_buildScreen(provider));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Rechazar'));
      await tester.pumpAndSettle();

      verify(() => mockService.rejectRequest(request)).called(1);
    });
  });

  group('FriendsScreen — sent requests', () {
    testWidgets('al abrir la pantalla se invoca loadSentRequests()', (tester) async {
      final provider = FriendsProvider(friendsService: mockService, uid: 'u1');

      await tester.pumpWidget(_buildScreen(provider));
      await tester.pumpAndSettle();

      verify(() => mockService.loadSentRequests('u1')).called(1);
    });

    testWidgets(
        "muestra la sección 'Solicitudes enviadas' con el destinatario y la etiqueta 'Pendiente'",
        (tester) async {
      const request =
          FriendRequest(fromUid: 'u1', fromUsername: 'ash', toUid: 'u2', toUsername: 'misty');
      when(() => mockService.loadSentRequests('u1')).thenAnswer((_) async => [request]);
      final provider = FriendsProvider(friendsService: mockService, uid: 'u1');

      await tester.pumpWidget(_buildScreen(provider));
      await tester.pumpAndSettle();

      expect(find.text('Solicitudes enviadas'), findsOneWidget);
      expect(find.text('misty'), findsOneWidget);
      expect(find.text('Pendiente'), findsOneWidget);
    });

    testWidgets("una solicitud enviada vieja (sin toUsername) cae al uid como etiqueta",
        (tester) async {
      const request = FriendRequest(fromUid: 'u1', fromUsername: 'ash', toUid: 'u2');
      when(() => mockService.loadSentRequests('u1')).thenAnswer((_) async => [request]);
      final provider = FriendsProvider(friendsService: mockService, uid: 'u1');

      await tester.pumpWidget(_buildScreen(provider));
      await tester.pumpAndSettle();

      expect(find.text('u2'), findsOneWidget);
    });

    testWidgets("sin solicitudes enviadas no se muestra la sección", (tester) async {
      final provider = FriendsProvider(friendsService: mockService, uid: 'u1');

      await tester.pumpWidget(_buildScreen(provider));
      await tester.pumpAndSettle();

      expect(find.text('Solicitudes enviadas'), findsNothing);
    });

    testWidgets('tocar cancelar en una solicitud enviada invoca cancelSentRequest(request)',
        (tester) async {
      const request = FriendRequest(fromUid: 'u1', fromUsername: 'ash', toUid: 'u2');
      when(() => mockService.loadSentRequests('u1')).thenAnswer((_) async => [request]);
      when(() => mockService.rejectRequest(any())).thenAnswer((_) async {});
      final provider = FriendsProvider(friendsService: mockService, uid: 'u1');

      await tester.pumpWidget(_buildScreen(provider));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      verify(() => mockService.rejectRequest(request)).called(1);
    });

    testWidgets(
        "un resultado de búsqueda cuyo uid está en sentRequestUids (persistido) aparece como 'Enviada' y deshabilitado",
        (tester) async {
      when(() => mockService.loadSentRequests('u1')).thenAnswer(
        (_) async => [const FriendRequest(fromUid: 'u1', fromUsername: 'ash', toUid: 'u9')],
      );
      when(() => mockService.searchUsers(any(), excludeUid: any(named: 'excludeUid')))
          .thenAnswer((_) async => [const UserSummary(uid: 'u9', username: 'brock')]);
      final provider = FriendsProvider(friendsService: mockService, uid: 'u1');

      await tester.pumpWidget(_buildScreen(provider));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'brock');
      await tester.pumpAndSettle();

      expect(find.text('brock'), findsWidgets);
      expect(find.text('Enviada'), findsWidgets);
      final button = tester.widget<TextButton>(
        find.ancestor(of: find.text('Enviada'), matching: find.byType(TextButton)).first,
      );
      expect(button.onPressed, isNull);
    });
  });

  group('FriendsScreen — pull-to-refresh', () {
    testWidgets('pull-to-refresh vuelve a invocar loadFriends, loadIncomingRequests y loadSentRequests',
        (tester) async {
      final provider = FriendsProvider(friendsService: mockService, uid: 'u1');

      await tester.pumpWidget(_buildScreen(provider));
      await tester.pumpAndSettle();
      clearInteractions(mockService);
      when(() => mockService.loadFriends(any())).thenAnswer((_) async => []);
      when(() => mockService.loadIncomingRequests(any())).thenAnswer((_) async => []);
      when(() => mockService.loadSentRequests(any())).thenAnswer((_) async => []);

      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pumpAndSettle();

      verify(() => mockService.loadFriends('u1')).called(1);
      verify(() => mockService.loadIncomingRequests('u1')).called(1);
      verify(() => mockService.loadSentRequests('u1')).called(1);
    });
  });
}
