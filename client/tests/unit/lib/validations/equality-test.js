import { module, test } from 'qunit';
import { validation } from 'tahi/lib/validations/equality';

module('validations/equality');

test('equal values', function(assert) {
  const value = true;
  const pass = validation(value, { value: true });

  assert.equal(pass, true, 'validation passed');
});

test('non equal values', function(assert) {
  const value = false;
  const pass = validation(value, { value: true });

  assert.equal(pass, false, 'validation failed');
});
