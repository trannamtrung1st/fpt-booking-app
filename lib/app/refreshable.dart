abstract class Refreshable {
  bool needRefresh = false;

  void updateKeepAlive();

  void refresh<T>({T refreshParam});
}
