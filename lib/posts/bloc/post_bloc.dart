import 'dart:async';
import 'dart:convert';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_infinite_list/posts/models/post.dart';
import 'package:stream_transform/stream_transform.dart';

part 'post_event.dart';

part 'post_state.dart';

const _postLimit = 20;

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc({required this.httpClient}) : super(const PostState()) {
    on<PostFetched>(
      _onPostFetched,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  final http.Client httpClient;

  Future<void> _onPostFetched(PostFetched event, Emitter<PostState> emit) async {
    print(state.status);

    if (state.hasReachedMax) return;
    try {
      if (state.status == PostStatus.INITIAL) {
        final posts = await _fetchPosts();
        return emit(state.copyWith(status: PostStatus.SUCCESS, posts: posts, hasReachedMax: false));
      }
      final posts = await _fetchPosts(state.posts.length);
      posts.isEmpty ? emit(state.copyWith(hasReachedMax: true)) : emit(state.copyWith(status: PostStatus.SUCCESS, hasReachedMax: false, posts: List.of(state.posts)..addAll(posts)));
    } catch (_) {
      emit(state.copyWith(status: PostStatus.FAILURE));
    }
  }

  Future<List<Post>> _fetchPosts([int startIndex = 0]) async {
    final response = await httpClient.get(
      Uri.https(
        'jsonplaceholder.typicode.com',
        '/posts',
        <String, String>{'_start': '$startIndex', '_limit': '$_postLimit'},
      ),
    );
    if (response.statusCode == 200) {
      final body = json.decode(response.body) as List;

      List<Post> posts = body.map((dynamic json) {
        return Post(
          id: json['id'] as int,
          title: json['title'] as String,
          body: json['body'] as String,
        );
      }).toList();

      return posts;
    }
    throw Exception('error fetching posts');
  }
}
