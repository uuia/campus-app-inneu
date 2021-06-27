class EventBus {

  static Map<String,List<Function>> _data = {};

  static addListener(String name, Function callback) {
    if(!_data.containsKey(name)) {
      _data[name] = List<Function>();
    }
    _data[name].add(callback);
  }

  static emitEvent(String name) {
    if (_data.containsKey(name)) {
      _data[name].forEach((element) {element();});
    }
  }
  
  static removeListen(String name, Function listener) {
    if (_data.containsKey(name)) {
      _data[name].remove(listener);
    }
  } 

}