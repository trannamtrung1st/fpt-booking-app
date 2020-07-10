abstract class Refreshable {
  bool needRefresh = false;

  void refresh<T>({T refreshParam});
}
