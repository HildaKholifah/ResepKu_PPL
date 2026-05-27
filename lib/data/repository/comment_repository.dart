import 'dart:convert';

import 'package:app_resepku/data/model/comment.dart';
import 'package:app_resepku/data/service/http_service.dart';

class CommentRepository {
  final HttpService httpService = HttpService();

  // ambil komentar berdasarkan recipe
  Future<List<Comment>> getComments(int recipeId) async {
    final response = await httpService.get('recipes/$recipeId/comments');

    final data = jsonDecode(response.body);

    final List comments = data['data'];

    return comments.map((item) => Comment.fromJson(item)).toList();
  }

  // tambah komentar
  Future<void> addComment(int recipeId, String comment) async {
    await httpService.post('recipes/$recipeId/comments', {'comment': comment});
  }
}
