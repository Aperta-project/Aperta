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

import Ember from 'ember';
const { isEmpty } = Ember;

// 1. Import validation:

import presence from 'tahi/lib/validations/presence';
import number   from 'tahi/lib/validations/number';
import email    from 'tahi/lib/validations/email';
import equality from 'tahi/lib/validations/equality';

// 2. Add imported validation to TYPES:

const TYPES = {
  'presence': presence.validation,
  'number': number.validation,
  'email': email.validation,
  'equality': equality.validation
};

// 3. Add imported validation defaultMessage:

const DEFAULT_MESSAGES = {
  'presence': presence.defaultMessage,
  'number': number.defaultMessage,
  'email': email.defaultMessage,
  'equality': equality.defaultMessage
};

// ---------------------------------

const _generateErrorMessage = function(type, customMessage) {
  if(isEmpty(customMessage)) {
    return DEFAULT_MESSAGES[type];
  }

  if(typeof customMessage === 'function') {
    return customMessage.call(this, type);
  }

  return customMessage;
};

export default {
  validate(key, value, validations) {
    const context = this;

    return _.compact(
      _.map(validations, function(validation) {
        // if validation is defined as { key: ['name'] }
        if(typeof validation === 'string') {
          const pass = TYPES[validation](value);
          if(!pass) {
            return _generateErrorMessage.call(context, validation);
          }
        }

        // if validation is defined with options:
        // { key: [{type: 'name', ...}] }
        if(typeof validation === 'object') {
          const options = _.clone(validation);
          const type = options.type;
          delete options.type;

          if(options.skipCheck && options.skipCheck.call(context, key, value)) {
            return;
          }

          let pass = false;
          if(options.validation) {
            pass = options.validation.call(context, key, value);
          } else {
            pass = TYPES[type](value, options);
          }

          if(!pass) {
            return _generateErrorMessage.call(context, type, options.message);
          }
        }
      })
    );
  }
};
