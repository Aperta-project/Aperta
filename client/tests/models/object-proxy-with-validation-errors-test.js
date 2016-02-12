import { module, test } from 'qunit';
import Ember from 'ember';
import ObjectProxyWithErrors from 'tahi/models/object-proxy-with-validation-errors';

module('ObjectProxyWithValidationErrors');

test('#validateKey with error', function(assert) {
  const proxyObject = ObjectProxyWithErrors.create({
    object: {
      'key': ''
    },

    validations: {
      'key': ['presence']
    }
  });

  proxyObject.validateKey('key');

  const errors = proxyObject.currentValidationErrors();
  assert.equal(errors.length, 1, 'errors found');
});

test('#validateKey without error', function(assert) {
  const proxyObject = ObjectProxyWithErrors.create({
    object: {
      'key': 'string'
    },

    validations: {
      'key': ['presence']
    }
  });

  proxyObject.validateKey('key');

  const errors = proxyObject.currentValidationErrors();
  assert.equal(errors.length, 0, 'no error found');
  assert.equal(
    proxyObject.get('errorsPresent'),
    false,
    'errorsPresent is false'
  );
});

test('#validateKey with error', function(assert) {
  const proxyObject = ObjectProxyWithErrors.create({
    object: {
      'key': ''
    },

    validations: {
      'key': ['presence']
    }
  });

  proxyObject.validateKey('key');

  const errors = proxyObject.currentValidationErrors();
  assert.equal(errors.length, 1, 'errors found');
  assert.equal(
    proxyObject.get('errorsPresent'),
    true,
    'errorsPresent is true'
  );
});

test('#validateAllKeys without error', function(assert) {
  const proxyObject = ObjectProxyWithErrors.create({
    object: {
      'key':  'string',
      'key2': 'string'
    },

    validations: {
      'key':  ['presence'],
      'key2': ['presence']
    }
  });

  proxyObject.validateAllKeys();

  const errors = proxyObject.currentValidationErrors();
  assert.equal(errors.length, 0, 'no error found');
  assert.equal(
    proxyObject.get('errorsPresent'),
    false,
    'errorsPresent is false'
  );
});

test('#validateAllKeys with error', function(assert) {
  const proxyObject = ObjectProxyWithErrors.create({
    object: {
      'key':  '',
      'key2': ''
    },

    validations: {
      'key':  ['presence'],
      'key2': ['presence']
    }
  });

  proxyObject.validateAllKeys();

  const errors = proxyObject.currentValidationErrors();
  assert.equal(errors.length, 3, 'errors found');
  assert.equal(
    proxyObject.get('errorsPresent'),
    true,
    'errorsPresent is true'
  );
});
