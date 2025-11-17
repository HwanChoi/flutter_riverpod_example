import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_application_demo/main.dart';
import 'package:flutter_application_demo/pages/fruit_list_page.dart';
import 'package:flutter_application_demo/pages/async_fruit_list_page.dart';
import 'package:flutter_application_demo/pages/hooks_examples_page.dart';
import 'package:flutter_application_demo/pages/injected_fruit_list_page.dart';
import 'package:flutter_application_demo/pages/auth_gate.dart';
import 'package:flutter_application_demo/examples/simple_provider_example.dart';
import 'package:flutter_application_demo/examples/state_provider_example.dart';
import 'package:flutter_application_demo/examples/state_notifier_provider_example.dart';
import 'package:flutter_application_demo/examples/coffee_shop_example.dart';
import 'package:flutter_application_demo/examples/api_call_example.dart';
import 'package:flutter_application_demo/music_player/screens/music_player_screen.dart';
import 'package:flutter_application_demo/examples/car_manufacturing_example.dart';
import 'package:flutter_application_demo/examples/stream_provider_example.dart';
import 'package:flutter_application_demo/examples/change_notifier_provider_example.dart';

/// 애플리케이션의 다양한 경로를 나타냅니다.
enum AppRoute {
  home,
  fruits,
  asyncFruits,
  hooksExamples,
  injectedFruits,
  authGate,
  simpleProvider,
  stateProvider,
  stateNotifierProvider,
  streamProvider,
  changeNotifierProvider,
  coffeeShop,
  carManufacturing,
  musicPlayer,
  apiExample,
}

/// 현재 내비게이션 스택을 보유하는 Riverpod 프로바이더입니다.
/// 스택은 [AppRoute] 목록이며, 마지막 항목이 현재 경로입니다.
final appRouterProvider = StateProvider<List<AppRoute>>((ref) => [AppRoute.home]);

/// [appRouterProvider]를 사용하여 내비게이터를 빌드하는 [RouterDelegate]입니다.
/// 이 델리게이트는 내비게이션 상태를 기반으로 페이지 스택을 빌드하고
/// 뒤로가기 버튼 누름을 처리하는 역할을 합니다.
class AppRouterDelegate extends RouterDelegate<List<AppRoute>>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<List<AppRoute>> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;
  final WidgetRef ref;

  /// [AppRouterDelegate]를 생성합니다.
  /// [ref]는 [appRouterProvider]를 수신하는 데 사용됩니다.
  AppRouterDelegate(this.ref) : navigatorKey = GlobalKey<NavigatorState>() {
    // appRouterProvider를 수신하고 변경될 때마다 리스너에게 알립니다.
    // 이렇게 하면 라우터가 새 스택으로 내비게이터를 다시 빌드합니다.
    ref.listen(appRouterProvider, (_, __) => notifyListeners());
  }

  /// 라우터의 현재 구성이며, 현재 내비게이션 스택입니다.
  @override
  List<AppRoute> get currentConfiguration => ref.read(appRouterProvider);

  /// 현재 페이지 스택으로 내비게이터를 빌드합니다.
  @override
  Widget build(BuildContext context) {
    final currentStack = ref.watch(appRouterProvider);
    return Navigator(
      key: navigatorKey,
      pages: currentStack.map((route) {
        switch (route) {
          case AppRoute.home:
            return MaterialPage(
              child: MyHomePage(title: 'Flutter Demo Home Page'),
            );
          case AppRoute.fruits:
            return MaterialPage(
              child: FruitListPage(),
            );
          case AppRoute.asyncFruits:
            return MaterialPage(
              child: AsyncFruitListPage(),
            );
          case AppRoute.hooksExamples:
            return MaterialPage(
              child: HooksExamplesPage(),
            );
          case AppRoute.injectedFruits:
            return MaterialPage(
              child: AuthGate(),
            );
          case AppRoute.simpleProvider:
            return MaterialPage(
              child: SimpleProviderExamplePage(),
            );
          case AppRoute.stateProvider:
            return MaterialPage(
              child: StateProviderExamplePage(),
            );
          case AppRoute.stateNotifierProvider:
            return MaterialPage(
              child: StateNotifierProviderExamplePage(),
            );
          case AppRoute.streamProvider:
            return const MaterialPage(
              child: StreamProviderExamplePage(),
            );
          case AppRoute.changeNotifierProvider:
            return const MaterialPage(
              child: ChangeNotifierProviderExamplePage(),
            );
          case AppRoute.coffeeShop:
            return MaterialPage(
              child: CoffeeShopPage(),
            );
          case AppRoute.carManufacturing:
            return MaterialPage(
              child: CarManufacturingPage(),
            );
          case AppRoute.musicPlayer:
            return const MaterialPage(
              child: MusicPlayerScreen(),
            );
          case AppRoute.apiExample:
            return const MaterialPage(
              child: ApiCallExamplePage(),
            );
          default:
            return MaterialPage(
              child: MyHomePage(title: 'Flutter Demo Home Page'),
            );
        }
      }).toList(),
      // 뒤로가기 버튼 누름을 처리합니다.
      onPopPage: (route, result) {
        // 경로를 팝할 수 없는 경우 OS가 팝을 처리하도록 합니다.
        if (!route.didPop(result)) {
          return false;
        }
        // 스택에 하나 이상의 경로가 있는 경우 마지막 경로를 팝합니다.
        final stack = ref.read(appRouterProvider);
        if (stack.length > 1) {
          ref.read(appRouterProvider.notifier).state =
              stack.sublist(0, stack.length - 1);
        }
        // 팝이 처리되었음을 나타내기 위해 true를 반환합니다.
        return true;
      },
    );
  }

  /// 라우터의 새 경로 경로를 설정합니다.
  /// 이는 새 경로가 구문 분석될 때 [AppRouteInformationParser]에 의해 호출됩니다.
  @override
  Future<void> setNewRoutePath(List<AppRoute> configuration) async {
    ref.read(appRouterProvider.notifier).state = configuration;
  }
}

/// OS에서 경로 정보를 구문 분석하고
/// 내비게이션 스택으로 변환하는 [RouteInformationParser]입니다.
class AppRouteInformationParser extends RouteInformationParser<List<AppRoute>> {
  /// 경로 정보를 구문 분석하고 내비게이션 스택을 반환합니다.
  @override
  Future<List<AppRoute>> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = routeInformation.uri;
    final segments = uri.pathSegments;
    // 세그먼트가 없으면 홈 경로를 반환합니다.
    if (segments.isEmpty) {
      return [AppRoute.home];
    }
    final routes = <AppRoute>[];
    // 각 세그먼트를 경로로 변환합니다.
    for (final segment in segments) {
      switch (segment) {
        case 'fruits':
          routes.add(AppRoute.fruits);
          break;
        case 'async-fruits':
          routes.add(AppRoute.asyncFruits);
          break;
        case 'hooks-examples':
          routes.add(AppRoute.hooksExamples);
          break;
        case 'injected-fruits':
          routes.add(AppRoute.injectedFruits);
          break;
        case 'auth':
          routes.add(AppRoute.authGate);
          break;
        case 'simple-provider':
          routes.add(AppRoute.simpleProvider);
          break;
        case 'state-provider':
          routes.add(AppRoute.stateProvider);
          break;
        case 'state-notifier-provider':
          routes.add(AppRoute.stateNotifierProvider);
          break;
        case 'stream-provider':
          routes.add(AppRoute.streamProvider);
          break;
        case 'change-notifier-provider':
          routes.add(AppRoute.changeNotifierProvider);
          break;
        case 'coffee-shop':
          routes.add(AppRoute.coffeeShop);
          break;
        case 'car-manufacturing':
          routes.add(AppRoute.carManufacturing);
          break;
        case 'music-player':
          routes.add(AppRoute.musicPlayer);
          break;
        case 'api-example':
          routes.add(AppRoute.apiExample);
          break;
        default:
          routes.add(AppRoute.home);
          break;
      }
    }
    return routes;
  }

  /// 내비게이션 스택에서 경로 정보를 복원합니다.
  /// 이는 브라우저의 URL을 업데이트하는 데 사용됩니다.
  @override
  RouteInformation restoreRouteInformation(List<AppRoute> configuration) {
    final location =
        configuration.map(_routeToPath).join('/');
    return RouteInformation(uri: Uri.parse(location));
  }

  /// 경로를 경로 세그먼트로 변환합니다.
  String _routeToPath(AppRoute route) {
    switch (route) {
      case AppRoute.fruits:
        return 'fruits';
      case AppRoute.asyncFruits:
        return 'async-fruits';
      case AppRoute.hooksExamples:
        return 'hooks-examples';
      case AppRoute.injectedFruits:
        return 'injected-fruits';
      case AppRoute.authGate:
        return 'auth';
      case AppRoute.simpleProvider:
        return 'simple-provider';
      case AppRoute.stateProvider:
        return 'state-provider';
      case AppRoute.stateNotifierProvider:
        return 'state-notifier-provider';
      case AppRoute.streamProvider:
        return 'stream-provider';
      case AppRoute.changeNotifierProvider:
        return 'change-notifier-provider';
      case AppRoute.coffeeShop:
        return 'coffee-shop';
      case AppRoute.carManufacturing:
        return 'car-manufacturing';
      case AppRoute.musicPlayer:
        return 'music-player';
      case AppRoute.apiExample:
        return 'api-example';
      default:
        return '';
    }
  }
}