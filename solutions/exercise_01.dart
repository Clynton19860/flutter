// Exercise 01: The greeting that will not compile
//
// Copy the field into a local first. The local can be promoted because nothing else can reassign it. `nickname?.toUpperCase() ?? ''` also works.

class Driver {
  String? nickname;

  String greet() {
    final n = nickname;
    if (n != null) {
      return 'Hello ${n.toUpperCase()}';
    }
    return 'Hello';
  }
}

void main() => print(Driver()..nickname = 'Sive');
