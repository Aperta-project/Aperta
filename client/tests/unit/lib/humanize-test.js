import { module, test } from 'qunit';
import humanize from 'tahi/lib/humanize';

module('Humanize');

test('humanizes snake case', function(assert) {
  let result = humanize('snake_case');
  assert.equal(result, 'Snake case', 'humanize from snake_case');
});

test('humanizes undefined value', function(assert) {
  let result = humanize(undefined);
  assert.equal(result, '', 'humanize for undefined');
});
