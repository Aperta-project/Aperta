import { module, test } from 'ember-qunit';
import { snapshotDiff } from 'tahi/lib/snapshot-diff';

module('Snapshot Diff');

test('compareSnapshots', function (assert) {
  let result = snapshotDiff('hello', 'world');
  assert.equal(result, 'hello world');
});