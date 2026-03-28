/// Returns [value] cast to [T] if possible, otherwise null.
T? tryCast<T>(Object? value) => value is T ? value : null;
