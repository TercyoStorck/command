import 'package:command/command.dart';

class CounterCommand extends Command<int> {
  CounterCommand(super.value);

  @override
  Future<int> action(currentValue) async {
    if (currentValue == null) {
      return 0;
    }

    final incrrementedValue = currentValue + 1;
    return incrrementedValue;
  }
}
