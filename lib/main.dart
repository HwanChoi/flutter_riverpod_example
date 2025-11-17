import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_application_demo/app_router.dart';
import 'package:flutter_application_demo/providers.dart'; // Import the new providers file

part 'main.g.dart';

@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;

  void increment() => state++;
}

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routerDelegate = AppRouterDelegate(ref);
    final routeInformationParser = AppRouteInformationParser();

    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerDelegate: routerDelegate,
      routeInformationParser: routeInformationParser,
    );
  }
}

class MyHomePage extends HookConsumerWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterProvider);
    final counterNotifier = ref.read(counterProvider.notifier);

    // Watch the global providers
    final globalCounter = ref.watch(globalCounterProvider);
    final welcomeMessage = ref.watch(welcomeMessageProvider);
    final generatedMessage = ref.watch(generatedMessageProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text('$counter', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 20),
            Text(welcomeMessage),
            Text(generatedMessage),
            Text('Global Counter: $globalCounter'),
            ElevatedButton(
              onPressed: () => ref.read(globalCounterProvider.notifier).state++,
              child: const Text('Increment Global Counter'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final stack = ref.read(appRouterProvider);
                ref.read(appRouterProvider.notifier).state = [
                  ...stack,
                  AppRoute.fruits,
                ];
              },
              child: const Text('Go to Fruit List'),
            ),
            ElevatedButton(
              onPressed: () {
                final stack = ref.read(appRouterProvider);
                ref.read(appRouterProvider.notifier).state = [
                  ...stack,
                  AppRoute.asyncFruits,
                ];
              },
              child: const Text('Go to Async Fruit List'),
            ),
            ElevatedButton(
              onPressed: () {
                final stack = ref.read(appRouterProvider);
                ref.read(appRouterProvider.notifier).state = [
                  ...stack,
                  AppRoute.hooksExamples,
                ];
              },
              child: const Text('Go to Hooks Examples'),
            ),
            ElevatedButton(
              onPressed: () {
                final stack = ref.read(appRouterProvider);
                ref.read(appRouterProvider.notifier).state = [
                  ...stack,
                  AppRoute.injectedFruits,
                ];
              },
              child: const Text('Go to Injected Fruit List'),
            ),
            ElevatedButton(
              onPressed: () {
                final stack = ref.read(appRouterProvider);
                ref.read(appRouterProvider.notifier).state = [
                  ...stack,
                  AppRoute.authGate,
                ];
              },
              child: const Text('Go to Login Example'),
            ),
            const SizedBox(height: 20),
            const Text('Dependency Injection Examples:'),
            ElevatedButton(
              onPressed: () {
                final stack = ref.read(appRouterProvider);
                ref.read(appRouterProvider.notifier).state = [
                  ...stack,
                  AppRoute.simpleProvider,
                ];
              },
              child: const Text('Go to Simple Provider Example'),
            ),
            ElevatedButton(
              onPressed: () {
                final stack = ref.read(appRouterProvider);
                ref.read(appRouterProvider.notifier).state = [
                  ...stack,
                  AppRoute.stateProvider,
                ];
              },
              child: const Text('Go to StateProvider Example'),
            ),
            ElevatedButton(
              onPressed: () {
                final stack = ref.read(appRouterProvider);
                ref.read(appRouterProvider.notifier).state = [
                  ...stack,
                  AppRoute.stateNotifierProvider,
                ];
              },
              child: const Text('Go to StateNotifierProvider Example'),
            ),
            ElevatedButton(
              onPressed: () {
                final stack = ref.read(appRouterProvider);
                ref.read(appRouterProvider.notifier).state = [
                  ...stack,
                  AppRoute.streamProvider,
                ];
              },
              child: const Text('Go to StreamProvider Example'),
            ),
            ElevatedButton(
              onPressed: () {
                final stack = ref.read(appRouterProvider);
                ref.read(appRouterProvider.notifier).state = [
                  ...stack,
                  AppRoute.changeNotifierProvider,
                ];
              },
              child: const Text('Go to ChangeNotifierProvider Example'),
            ),
            ElevatedButton(
              onPressed: () {
                final stack = ref.read(appRouterProvider);
                ref.read(appRouterProvider.notifier).state = [
                  ...stack,
                  AppRoute.coffeeShop,
                ];
              },
              child: const Text('Go to Coffee Shop Example'),
            ),
            ElevatedButton(
              onPressed: () {
                final stack = ref.read(appRouterProvider);
                ref.read(appRouterProvider.notifier).state = [
                  ...stack,
                  AppRoute.carManufacturing,
                ];
              },
              child: const Text('Go to Car Manufacturing Example'),
            ),
            ElevatedButton(
              onPressed: () {
                final stack = ref.read(appRouterProvider);
                ref.read(appRouterProvider.notifier).state = [
                  ...stack,
                  AppRoute.musicPlayer,
                ];
              },
              child: const Text('Go to Music Player'),
            ),
            ElevatedButton(
              onPressed: () {
                final stack = ref.read(appRouterProvider);
                ref.read(appRouterProvider.notifier).state = [
                  ...stack,
                  AppRoute.apiExample,
                ];
              },
              child: const Text('Go to API Call Example'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: counterNotifier.increment,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
