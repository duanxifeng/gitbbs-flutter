import 'package:fish_redux/fish_redux.dart';
import 'package:gitbbs/ui/favoritelist/action.dart';
import 'package:gitbbs/ui/favoritelist/state.dart';

Reducer<FavoriteListState> buildReducer() {
  return asReducer<FavoriteListState>(<Object, Reducer<FavoriteListState>>{
    FavoriteListAction.updateData: _initData
  });
}

FavoriteListState _initData(FavoriteListState state, Action action) {
  FavoriteListState newState = state.clone();
  newState.list = List.of(action.payload.reversed);
  return newState;
}
