/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

import { module, test } from 'qunit';
import ObjectProxyWithErrors from 'tahi/pods/object-proxy-with-validation-errors/model';

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
