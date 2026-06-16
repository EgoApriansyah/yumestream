class PaginationModel {
  final int currentPage;
  final bool hasPrevPage;
  final int? prevPage;
  final bool hasNextPage;
  final int? nextPage;
  final int totalPages;

  const PaginationModel({
    required this.currentPage,
    required this.hasPrevPage,
    this.prevPage,
    required this.hasNextPage,
    this.nextPage,
    required this.totalPages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      currentPage: json['currentPage'] as int? ?? 1,
      hasPrevPage: json['hasPrevPage'] as bool? ?? false,
      prevPage: json['prevPage'] as int?,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
      nextPage: json['nextPage'] as int?,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }
}
