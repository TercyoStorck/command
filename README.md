# Command

__dart_command__ is a package that will help you to create commands according to Command Pattern as described on [The command pattern](https://docs.flutter.dev/app-architecture/design-patterns/command).

With this package you'll can use command on __ListenableBuilder__ (ChangeNotifier) as well __StreamBuilder__ (Streams).

# Usage

We have basicly two ways to use Command. First as inheritance:

``` dart
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
    final incrrementedValue = currentValue + 1;
    return incrrementedValue;
  }
}
```

And we'll can instantiate like this:

``` dart
final _counterCommand = CounterCommand(0);
```
And another way by factory:

``` dart
final _randomNumberCommand = Command.crerate(
    value: 0,
    action: (_) async {
        return Random().nextInt(100);
    },
);
```
_Command_ have a closure called _action_. This is where you'll do your logic and return te result to command.

## Validate

One of the methods you can override is `validate(currentValue)`. It passes the current value and you just do logical validations inside it.

``` dart
@override
void validate(int currentValue) {
    if (currentValue >= 10) {
        throw 'Value can\'t be more than 10';
    }
}
```
## Action

`action(currentValue)` is the method that'll called when `execute()` is called. Inside it you must have to put what you want to execute after `validate`.

```dart
@override
Future<int> action(currentValue) async {
    final incrementedValue = currentValue + 1;
    return incrementedValue;
}
```

## ListenableBuilder and StreamBuilder

Now you just passa these commands to __ListenableBuilder__ or __StreamBuilder__.

### ListenableBuilder and ValueListenableBuilder usage:

``` dart
ListenableBuilder(
    listenable: _counterCommand,
    builder: (context, child) {
        return Text(
            'Counte Command as Listenable (ChangeNotify) = ${_counterCommand.value}',
            style: Theme.of(context).textTheme.headlineMedium,
        );
    },
)
```
or

``` dart
ValueListenableBuilder(
    valueListenable: _counterCommand,
    builder: (context, i, child) {
        return Text(
            'Counte Command as ValueListenable (ChangeNotify) = ${_counterCommand.value}',
            style: Theme.of(context).textTheme.headlineMedium,
        );
    },
),
```
### StreamBuilder usage:

``` dart
StreamBuilder<int>(
    stream: _randomNumberCommand,
    builder: (context, snapshot) {
        return Text(
            'Random number Command as Stream = ${snapshot.data}',
            style: Theme.of(context).textTheme.headlineMedium,
        );
    },
)
```
## State

Every command have a state. For every moment that the command is, one state will be. To get state just `Command.state`

```
    Created
    Running
    Error
    Completed
```

## Value and Error

At any time you can get a value or error from command. To get value just `Command.value` and for the error do `Command.errorWrapper`.

The _ErrorWrapper_ have Object with error and the stackTrace.

## Execute a command

For the last but not least. To execute the command just call `Command.execute()` mehtod. This is a asynchronous way to execute the command and you can get the resuult on Builders (Listenable or Stream) or just call `.value` as describled above.

If you want to get result of command just after `Command.execute()` you may pass a _closure_ as bellow.

``` dart
_counterCommand.execute(
    onCompleted: (value) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Counter: $value')),
        );
    },
    onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${error.error}')),
        );
    },
)
```

Another way to execute the command is using `Command.executeAsync()`. It's a `Future<T>` so, that way you can wating for the result.

## Another features

__Command__ have all features that `Stream` and `ValueListenable` have. So you can enjoy these features too.