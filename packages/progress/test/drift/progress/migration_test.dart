import 'package:drift_dev/api/migrations_native.dart';
import 'package:progress/progress.dart';
import 'package:test/test.dart';

import 'generated/schema.dart';

void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('cada versión del esquema tiene su volcado en drift_schemas/', () {
    expect(GeneratedHelper.versions.last, ProgressDatabase.currentSchemaVersion);
  });

  test('el esquema actual coincide con el volcado de su versión', () async {
    final connection = await verifier.startAt(ProgressDatabase.currentSchemaVersion);
    final db = ProgressDatabase(connection);
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, ProgressDatabase.currentSchemaVersion);
  });
}
