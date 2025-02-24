import 'package:command/command.dart';

class CounterCommand extends Command<int> {
  CounterCommand(super.value);

  @override
  void validate(int currentValue) {
    if (currentValue >= 10) {
      throw 'Value can\'t be more than 10';
    }
  }

  @override
  Future<int> action(currentValue) async {
    final incrementedValue = currentValue + 1;
    return incrementedValue;
  }
}
