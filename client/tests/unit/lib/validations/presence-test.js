import { module, test } from 'qunit';
import { validation } from 'tahi/lib/validations/presence';

module('validations/presence');

test('null', function(assert) {
  const value = null;
  const pass = validation(value);

  assert.equal(pass, false, 'validation failed');
});

test('empty string', function(assert) {
  const value = '';
  const pass = validation(value);

  assert.equal(pass, false, 'validation failed');
});

test('string with space', function(assert) {
  const value = ' ';
  const pass = validation(value);

  assert.equal(pass, false, 'validation failed');
});

test('integer of zero', function(assert) {
  const value = 0;
  const pass = validation(value);

  assert.equal(pass, true, 'validation passed');
});
