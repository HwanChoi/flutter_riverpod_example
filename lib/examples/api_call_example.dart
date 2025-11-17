import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

// 1. 데이터 모델 (Data Model)
// -------------------------------------------------

/// API로부터 받아올 게시글 데이터를 표현하는 불변(immutable) 클래스입니다.
@immutable
class Post {
  const Post({required this.id, required this.title, required this.body});
  final int id;
  final String title;
  final String body;

  /// JSON으로부터 Post 객체를 생성하는 팩토리 생성자
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }
}

// 2. 실제 API 서비스 (Real API Service)
// -------------------------------------------------

/// 네트워크 통신을 통해 실제 API를 호출하는 서비스 클래스입니다.
class ApiService {
  final String _baseUrl = 'https://jsonplaceholder.typicode.com';

  /// 게시글 목록을 비동기적으로 가져옵니다.
  Future<List<Post>> getPosts() async {
    print('API: 실제 네트워크에서 게시글 데이터를 요청합니다...');
    try {
      final response = await http.get(Uri.parse('$_baseUrl/posts'));

      if (response.statusCode == 200) {
        // 성공적으로 데이터를 받아왔을 경우
        final List<dynamic> jsonData = jsonDecode(response.body);
        final posts = jsonData.map((json) => Post.fromJson(json)).toList();
        print('API: 성공적으로 데이터를 파싱하고 반환합니다.');
        return posts;
      } else {
        // 서버에서 에러 응답을 보냈을 경우
        print('API: 서버 에러 발생. Status Code: ${response.statusCode}');
        throw Exception('Failed to load posts (Status Code: ${response.statusCode})');
      }
    } catch (e) {
      // 네트워크 연결 실패 등 http 요청 자체에서 에러가 발생했을 경우
      print('API: 네트워크 요청 중 오류 발생: $e');
      throw Exception('Failed to connect to the server: $e');
    }
  }
}

// 3. Riverpod Provider 설정
// -------------------------------------------------

/// `ApiService`의 인스턴스를 제공하는 Provider입니다.
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

/// `FutureProvider`를 사용하여 실제 API로부터 게시글 데이터를 가져옵니다.
final postsProvider = FutureProvider<List<Post>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getPosts();
});


// 4. UI (User Interface)
// -------------------------------------------------

class ApiCallExamplePage extends ConsumerWidget {
  const ApiCallExamplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPosts = ref.watch(postsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Real API Call Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(postsProvider);
            },
          ),
        ],
      ),
      body: Center(
        child: asyncPosts.when(
          data: (posts) => ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return ListTile(
                leading: CircleAvatar(child: Text(post.id.toString())),
                title: Text(post.title),
                subtitle: Text(post.body, maxLines: 1, overflow: TextOverflow.ellipsis),
              );
            },
          ),
          loading: () => const CircularProgressIndicator(),
          error: (error, stackTrace) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                Text(
                  'Error: $error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => ref.refresh(postsProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
