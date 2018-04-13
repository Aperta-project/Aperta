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
import prepper from 'tahi/lib/validations/prepare-response-errors';

module('validations/prepareResponseErrors');

test('with only string details', function(assert) {
  const apiErrors = [
    {
      'detail': 'some error',
      'source': {'pointer': '/path/to/resource'},
      'title': 'title'
    },
    {
      'detail': 'some other error',
      'source': {'pointer': '/path/to/other'},
      'title': 'other title'
    }
  ];

  const errors = prepper(apiErrors, undefined);

  assert.equal(errors['resource'], apiErrors[0]['detail']);
  assert.equal(errors['other'], apiErrors[1]['detail']);
});

test('with an object detail', function(assert) {
  const apiErrors = [
    {
      'detail': {
        1: {'category': ['can`t be blank']}
      },
      'source': {'pointer': '/path/to/resource'},
      'title': 'title'
    },
    {
      'detail': {
        1: {'category': ['can`t be wrong']}
      },
      'source': {'pointer': '/path/to/other'},
      'title': 'other title'
    }
  ];

  const errors = prepper(apiErrors, undefined);

  assert.equal(errors.resource[1], apiErrors[0].detail[1]);
  assert.equal(errors.resource[1], apiErrors[0].detail[1]);
});
