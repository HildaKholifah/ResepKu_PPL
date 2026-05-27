class RecipeRequest {
  final String? search;
  final int? userId;

  RecipeRequest({this.search, this.userId});

  Map<String, dynamic> toMap() {
    return {
      if (search != null) 'search': search,
      if (userId != null) 'user_id': userId,
    };
  }
}
