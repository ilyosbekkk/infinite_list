import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_infinite_list/posts/bloc/post_bloc.dart';
import 'package:flutter_infinite_list/posts/widgets/bottom_loader.dart';
import 'package:flutter_infinite_list/posts/widgets/post_list_item.dart';

class PostsList extends StatefulWidget {
  const PostsList({Key? key}) : super(key: key);

  @override
  _PostsListState createState() => _PostsListState();
}

class _PostsListState extends State<PostsList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostBloc, PostState>(builder: (context, state) {
      switch (state.status) {
        case PostStatus.FAILURE:
          return Center(
            child: Text("Failed to  fetch posts:("),
          );
        case PostStatus.SUCCESS:
          if (state.posts.isEmpty) {
            return const Center(
              child: Text("No posts to show"),
            );
          }
          return ListView.builder(
              controller: _scrollController,
              itemCount: state.hasReachedMax ? state.posts.length : state.posts.length + 1,
              itemBuilder: (BuildContext context, index) {
                return index >= state.posts.length ? BottomLoader() : PostListItem(post: state.posts[index]);
              });

        default:
          return const Center(child: CircularProgressIndicator());

      }
    });
  }

  @override
  void dispose() {
    super.dispose();
   _scrollController..removeListener(_onScroll)..dispose();

  }
  void _onScroll() {
    if (_isBottom) context.read<PostBloc>().add(PostFetched());
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

}
