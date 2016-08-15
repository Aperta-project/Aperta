import { module, test } from 'qunit';
import ObjectProxyWithErrors from 'tahi/models/object-proxy-with-validation-errors';

module('ObjectProxyWithValidationErrors');

test('#validateProperty with error', function(assert) {
  const proxyObject = ObjectProxyWithErrors.create({
    object: {
      'key': ''
    },

    validations: {
      'key': ['presence']
    }
  });

  proxyObject.validateProperty('key');

  assert.equal(proxyObject.validationErrorsPresent(), true, 'errors found');
});

test('#validateProperty without error', function(assert) {
  const proxyObject = ObjectProxyWithErrors.create({
    object: {
      'key': 'string'
    },

    validations: {
      'key': ['presence']
    }
  });

  proxyObject.validateProperty('key');

  assert.equal(proxyObject.validationErrorsPresent(), false, 'no error found');
  assert.equal(
    proxyObject.get('errorsPresent'),
    false,
    'errorsPresent is false'
  );
});

test('#validateProperty with error', function(assert) {
  const proxyObject = ObjectProxyWithErrors.create({
    object: {
      'key': ''
    },

    validations: {
      'key': ['presence']
    }
  });

  proxyObject.validateProperty('key');

  assert.equal(proxyObject.validationErrorsPresent(), true, 'errors found');
  assert.equal(
    proxyObject.get('errorsPresent'),
    true,
    'errorsPresent is true'
  );
});

test('#validateAll without error', function(assert) {
  const proxyObject = ObjectProxyWithErrors.create({

    object: {
      'key':  'string',
      'key2': 'string',
      'ident--key': 'string',
      'ident--key2': 'string',
      findQuestion() { return 'string'; },
    },

    validations: {
      'key':  ['presence'],
      'key2': ['presence']
    },

    questionValidations: {
      'ident--key':  ['presence'],
      'ident--key2': ['presence']
    }
  });

  proxyObject.validateAll();

  assert.equal(proxyObject.validationErrorsPresent(), false, 'no error found');
  assert.equal(
    proxyObject.get('errorsPresent'),
    false,
    'errorsPresent is false'
  );
});

test('#validateAll with error', function(assert) {
  const proxyObject = ObjectProxyWithErrors.create({
    object: {
      'key':  '',
      'key2': '',
      'ident--key': '',
      'ident--key2': '',
      findQuestion() { return ''; },
    },

    validations: {
      'key':  ['presence'],
      'key2': ['presence']
    },

    questionValidations: {
      'ident--key':  ['presence'],
      'ident--key2': ['presence']
    }
  });

  proxyObject.validateAll();

  const errors = proxyObject.validationErrorsPresent();
  assert.equal(proxyObject.validationErrorsPresent(), true, 'errors found');
  assert.equal(
    proxyObject.get('errorsPresent'),
    true,
    'errorsPresent is true'
  );
});
