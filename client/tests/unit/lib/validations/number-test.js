import { module, test } from 'qunit';
import { validation } from 'tahi/lib/validations/number';

module('validations/number');

test('string with letters', function(assert) {
  const value = 'test';
  const pass = validation(value);

  assert.equal(pass, false, 'validation failed');
});

test('string with number', function(assert) {
  const value = '100';
  const pass = validation(value);

  assert.equal(pass, true, 'validation pass');
});

test('string with numbers and letters', function(assert) {
  const value = '100x';
  const pass = validation(value);

  assert.equal(pass, false, 'validation failed');
});

test('integer with zero', function(assert) {
  const value = 0;
  const pass = validation(value);

  assert.equal(pass, true, 'validation passed');
});

test('float', function(assert) {
  const value = 10.01;
  const pass = validation(value);

  assert.equal(pass, true, 'validation passed');
});

test('blank value, allow blank', function(assert) {
  const value = null;
  const options = { allowBlank: true };
  const pass = validation(value, options);

  assert.equal(pass, true, 'validation passed');
});

test('null', function(assert) {
  const value = null;
  const pass = validation(value);

  assert.equal(pass, false, 'validation failed');
});

test('undefined', function(assert) {
  const pass = validation();

  assert.equal(pass, false, 'validation failed');
});
