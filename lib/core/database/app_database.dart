/// Local persistence entry point (e.g. drift/isar/sqflite).
///
/// Implement and register when you add on-device storage.
abstract class AppDatabase {
  Future<void> close();
}
