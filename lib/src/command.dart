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
  ValueCallback<T>? _onCompleted;
  ErrorCallback? _onError;

  Command([T? value]) : _value = value as T;

  static Command<T> create<T>({
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

  Future<T> action(T currentValue);
  void validate(T currentValue);

  void _notifyListeners() {
    if (_state == CommandState.error) {
      _strreamController?.addError(
        _errorWrapper!.error,
        _errorWrapper?.stackTrace,
      );

      _onError?.call(_errorWrapper!);
    } else {
      _strreamController?.add(_value);
    }

    if (_state == CommandState.completed) {
      _onCompleted?.call(_value);
    }

    for (var listener in _listeners) {
      listener?.call();
    }
  }

  void execute({
    ValueCallback<T>? onCompleted,
    ErrorCallback? onError,
  }) {
    _onCompleted = onCompleted;
    _onError = onError;

    this.executeAsync().whenComplete(
      () {
        _onCompleted = null;
        _onError = null;
      },
    );
  }

  Future<T> executeAsync() async {
    if (_state == CommandState.running) {
      return _value;
    }

    _state = CommandState.running;
    _errorWrapper = null;
    _notifyListeners();

    try {
      this.validate(_value);

      final rersult = await this.action(_value);

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

    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        _strreamController?.add(_value);
      },
    );

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
  final VoidCallback? _validate;

  _Command(
    super.value, {
    required Future<T> Function(T? value) action,
    VoidCallback? validate,
  })  : _action = action,
        _validate = validate;

  @override
  void validate(T? currentValue) => _validate?.call();

  @override
  Future<T> action(T? value) async => await _action(value);
}

typedef ValueCallback<T> = void Function(T value);
typedef ErrorCallback = void Function(ErrorWrapper error);
