class PageResult<T> {
  final List<T> items;
  final int page;
  final int size;
  final int total;

  const PageResult({
    required this.items,
    required this.page,
    required this.size,
    required this.total,
  });

  int get totalPages {
    if (total == 0) {
      return 1;
    }

    return (total / size).ceil();
  }

  bool get hasPrevious => page > 1;

  bool get hasNext => page < totalPages;

  PageResult.empty({this.size = 10})
      : items = <T>[],
        page = 1,
        total = 0;
}