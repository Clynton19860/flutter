class Driver {
  String? nickname;

  String greet() {
    if (nickname != null) {
      return 'Hello ${nickname?.toUpperCase()}';
    }
    return 'Hello';
  }
}

void main() => print(Driver()..nickname = 'Sive');