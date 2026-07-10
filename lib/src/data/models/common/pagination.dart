class Pagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  Pagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json["total"],
      page: json["page"],
      limit: json["limit"],
      totalPages: json["totalPages"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "total": total,
      "page": page,
      "limit": limit,
      "totalPages": totalPages,
    };
  }
}
