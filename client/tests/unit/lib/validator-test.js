import { module, test } from 'qunit';
import validator from 'tahi/lib/validator';

module('validator');

test('one validation, no options, no errors', function(assert) {
  const key   = 'key';
  const value = 'test';
  const validations = ['presence'];

  const messages = validator.validate(key, value, validations);

  assert.equal(messages.length, 0, 'No error messages');
});

test('one validation, no options, one error', function(assert) {
  const key   = 'key';
  const value = null;
  const validations = ['presence'];

  const messages = validator.validate(key, value, validations);

  assert.equal(messages.length, 1, 'One error message');
});

test('two validations, no options, one error', function(assert) {
  const key   = 'key';
  const value = 'two';
  const validations = ['presence', 'number'];

  const messages = validator.validate(key, value, validations);

  assert.equal(messages.length, 1, 'One error message');
});

test('two validations, no options, two errors', function(assert) {
  const key   = 'key';
  const value = null;
  const validations = ['number', 'presence'];

  const messages = validator.validate(key, value, validations);

  assert.equal(messages.length, 2, 'Two error messages');
});

test('one validation, options, no errors', function(assert) {
  const key   = 'key';
  const value = null;
  const validations = [{type: 'number', allowBlank: true}];

  const messages = validator.validate(key, value, validations);

  assert.equal(messages.length, 0, 'No error messages');
});

test('one validation, options with skipCheck true, no errors', function(assert) {
  const key   = 'key';
  const value = 'string';
  const validations = [{
    type: 'number',
    skipCheck: function() { return true; }
  }];

  const messages = validator.validate(key, value, validations);

  assert.equal(messages.length, 0, 'No error messages');
});

test('one validation, options with skipCheck false, errors', function(assert) {
  const key   = 'key';
  const value = 'string';
  const validations = [{
    type: 'number',
    skipCheck: function() { return false; }
  }];

  const messages = validator.validate(key, value, validations);

  assert.equal(messages.length, 1, 'Error message');
});

test('one validation, options with custom message', function(assert) {
  const customMessage = 'fix it';
  const key   = 'key';
  const value = null;
  const validations = [{
    type: 'presence',
    message: customMessage
  }];

  const messages = validator.validate(key, value, validations);

  assert.equal(messages[0], customMessage, 'Custom message');
});

test('one validation, options with custom message function', function(assert) {
  const customMessage = 'fix me';
  const key   = 'key';
  const value = null;
  const validations = [{
    type: 'presence',
    message() {
      return customMessage;
    }
  }];

  const messages = validator.validate(key, value, validations);

  assert.equal(messages[0], customMessage, 'Custom message function');
});
