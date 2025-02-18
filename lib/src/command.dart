import 'dart:async';

import 'package:flutter/foundation.dart';

import 'command_state.dart';
import 'error_wrapper.dart';

export 'command_state.dart';
export 'error_wrapper.dart';

abstract class Command<T> with Stream<T> implements ValueListenable<T> {
  final List<VoidCallback?> _listeners = [];

  T _value;
  StreamController<T>? _strreamController;
  CommandState _state = CommandState.created;
  ErrorWrapper? _errorWrapper;

  Command([T? value]) : _value = value as T;

  static Command<T> crerate<T>({
    T? value,
    required Future<T> Function(T? value) action,
  }) {
    return _Command<T>(
      value,
      action: action,
    );
  }

  @override
  T get value => _value;
  CommandState get state => _state;
  ErrorWrapper? get errorWrapper => _errorWrapper;

  Future<T> action(T? currentValue);

  void _notifyListeners() {
    if (_state == CommandState.error) {
      _strreamController?.addError(
        _errorWrapper!.error,
        _errorWrapper?.stackTrace,
      );
    }

    _strreamController?.add(_value);

    for (var listener in _listeners) {
      listener?.call();
    }
  }

  void execute() async {
    this.executeAsync();
  }

  Future<T> executeAsync() async {
    _state = CommandState.running;

    try {
      final rersult = await action(_value);

      _value = rersult;
      _state = CommandState.completed;

      return _value;
    } catch (error, stackTrace) {
      _errorWrapper = ErrorWrapper(error, stackTrace);
      _state = CommandState.error;

      throw _errorWrapper!;
    } finally {
      _notifyListeners();
    }
  }

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  @override
  StreamSubscription<T> listen(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    _strreamController ??= StreamController<T>.broadcast();

    if (_value != null) {
      Future.delayed(
        const Duration(milliseconds: 100),
        () {
          _strreamController?.add(_value);
        },
      );
    }

    return _strreamController!.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @mustCallSuper
  void dispose() {
    if (kFlutterMemoryAllocationsEnabled) {
      FlutterMemoryAllocations.instance.dispatchObjectDisposed(object: this);
    }

    _listeners.clear();
    _strreamController?.close();
  }
}

class _Command<T> extends Command<T> {
  final Future<T> Function(T? value) _action;

  _Command(
    super.value, {
    required Future<T> Function(T? value) action,
  }) : _action = action;

  @override
  Future<T> action(T? value) async => await _action(value);
}
