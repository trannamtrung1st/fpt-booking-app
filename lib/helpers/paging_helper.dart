class Paging {
  int currentPage;
  int itemsPerPage;
  int pagesPerLoad;

  int totalPages;
  int firstVisiblePage;
  int lastVisiblePage;
  List<int> visiblePages = <int>[];

  bool isActivePage(int page) {
    return currentPage == page;
  }

  void countPage(int totalItems) {
    totalPages = (totalItems ~/ itemsPerPage) + 1;
    totalPages = (totalItems % itemsPerPage) == 0 ? totalPages - 1 : totalPages;

    int diff = pagesPerLoad ~/ 2;
    lastVisiblePage = currentPage + diff;
    firstVisiblePage = currentPage - diff + (pagesPerLoad % 2 == 0 ? 1 : 0);
    if (lastVisiblePage > totalPages) {
      firstVisiblePage -= lastVisiblePage - totalPages;
      lastVisiblePage = totalPages;
    }
    if (firstVisiblePage < 1) {
      lastVisiblePage += 1 - firstVisiblePage;
      firstVisiblePage = 1;
    }
    firstVisiblePage = firstVisiblePage > 0 ? firstVisiblePage : 1;
    lastVisiblePage =
        lastVisiblePage <= totalPages ? lastVisiblePage : totalPages;
    //for 2 pages first, last
    if (firstVisiblePage >= 2) firstVisiblePage += 1;
    if (lastVisiblePage <= totalPages - 1) lastVisiblePage -= 1;

    for (var i = firstVisiblePage; i <= lastVisiblePage; i++)
      visiblePages.add(i);
  }

  T returnIf<T>(int page, T valIfPageActive, T valIfPageNoneActive) {
    return isActivePage(page) ? valIfPageActive : valIfPageNoneActive;
  }
}
