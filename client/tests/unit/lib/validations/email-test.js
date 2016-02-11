import { module, test } from 'qunit';
import { validation } from 'tahi/lib/validations/email';

module('validations/email');

test('null', function(assert) {
  const value = null;
  const pass = validation(value);

  assert.equal(pass, false, 'validation failed');
});

test('missing @', function(assert) {
  const value = 'testexample.com';
  const pass = validation(value);

  assert.equal(pass, false, 'validation failed');
});

test('missing .', function(assert) {
  const value = 'test@examplecom';
  const pass = validation(value);

  assert.equal(pass, false, 'validation failed');
});

test('valid addresses', function(assert) {
  assert.equal(validation('t@example.com'), true, 'validation 1 passed');
  assert.equal(validation('t+2@example.com'), true, 'validation 1 passed');
  assert.equal(validation('t_3@example-test.io'), true, 'validation 1 passed');
});
