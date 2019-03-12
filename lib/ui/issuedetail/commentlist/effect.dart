import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';
import 'package:gitbbs/model/entry/comment_edit_data.dart';
import 'package:gitbbs/network/GitHttpRequest.dart';
import 'package:gitbbs/network/github/GithubHttpRequest.dart';
import 'package:gitbbs/ui/editcomment/edit_comment_page.dart';
import 'package:gitbbs/ui/issuedetail/commentlist/action.dart';
import 'package:gitbbs/ui/issuedetail/commentlist/state.dart';
import 'package:gitbbs/util/issue_cache_manager.dart';

Effect<CommentListState> buildEffect() {
  return combineEffects(<Object, Effect<CommentListState>>{
    Lifecycle.initState: _init,
    CommentListAction.refresh: _refresh,
    CommentListAction.loadMore: _loadMore,
    CommentListAction.editComment: _editComment,
    CommentListAction.replyComment: _reply,
    CommentListAction.queryDeleteComment: _queryDeleteComment,
    CommentListAction.deleteComment: _deleteComment
  });
}

void _init(Action action, Context<CommentListState> ctx) async {
  var cache = IssueCacheManager.getIssueComments(ctx.state.issue.getNumber());
  if (cache != null) {
    ctx.dispatch(CommentListActionCreator.refreshedAction(cache));
  }
  GitHttpRequest request = GithubHttpRequest.getInstance();
  var pagingData = await request.getComments(ctx.state.issue.getNumber(), null);
  ctx.dispatch(CommentListActionCreator.refreshedAction(pagingData));
}

void _refresh(Action action, Context<CommentListState> ctx) async {
  GitHttpRequest request = GithubHttpRequest.getInstance();
  var pagingData = await request.getComments(ctx.state.issue.getNumber(), null);
  ctx.dispatch(CommentListActionCreator.refreshedAction(pagingData));
}

void _loadMore(Action action, Context<CommentListState> ctx) async {
  String cursor = ctx.state.list.last?.getCursor();
  GitHttpRequest request = GithubHttpRequest.getInstance();
  var pagingData =
      await request.getComments(ctx.state.issue.getNumber(), cursor);
  ctx.dispatch(CommentListActionCreator.onMoreLoadedAction(pagingData));
}

void _editComment(Action action, Context<CommentListState> ctx) {
  Navigator.of(ctx.context).push(MaterialPageRoute(
      builder: (context) => EditCommentPage().buildPage(CommentEditData(
          ctx.state.issue, Type.modify,
          comment: action.payload))));
}

void _reply(Action action, Context<CommentListState> ctx) {
  Navigator.of(ctx.context).push(MaterialPageRoute(
      builder: (context) => EditCommentPage().buildPage(CommentEditData(
          ctx.state.issue, Type.reply,
          comment: action.payload))));
}

void _queryDeleteComment(Action action, Context<CommentListState> ctx) {
  showDialog(
      context: ctx.context,
      builder: (context) {
        return AlertDialog(
          title: Text('提示'),
          content: Text('是否删除评论？'),
          actions: <Widget>[
            FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('取消')),
            FlatButton(
                onPressed: () {
                  ctx.dispatch(CommentListActionCreator.deleteCommentAction(
                      action.payload));
                  Navigator.of(context).pop();
                },
                child: Text('确定')),
          ],
        );
      });
}

void _deleteComment(Action action, Context<CommentListState> ctx) async {
  GitHttpRequest request = GithubHttpRequest.getInstance();
  var success = await request.deleteComment(action.payload.getId());
  if (success) {
    ctx.dispatch(
        CommentListActionCreator.onCommentDeletedAction(action.payload));
  }
}