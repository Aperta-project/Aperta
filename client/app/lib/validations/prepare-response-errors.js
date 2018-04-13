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
import deepJoinArrays from 'tahi/lib/deep-join-arrays';
import deepCamelizeKeys from 'tahi/lib/deep-camelize-keys';
import humanizeStr from 'tahi/lib/humanize';

//errors will look something like [{detail, source: {pointer}}]
//unless they're adapter related errors that don't return a JSON-API error
//response, in which they're more like [{title, detail}]
function createLegacyErrors(errors) {
  let errorObj = {};
  let errorKey;
  errors.forEach(({source, detail}) => {
    errorKey = (Ember.isNone(source)) ?  detail : source.pointer.split('/').pop();

    if(typeof(detail) === 'object') {
      Object.keys(detail).forEach(function(key) {
        detail[key] = detail[key]['category'][0];
      });
      errorObj[errorKey] = detail;
    } else {
      if (!errorObj[errorKey]) { errorObj[errorKey] = []; }
      errorObj[errorKey].push(detail);
    }
  });

  return errorObj;
}

function formatKey(key, humanize) {
  return humanize ? humanizeStr(key.underscore()) : key.capitalize();
}

/**
  Take response from Rails, camelize keys and join arrays.
  Passing `includeNames: true` or `includeNames: 'humanize'`
  will return the formatted name of the error key with a joined
  list of errors instead of an array.

  @private
  @method prepareResponseErrors
  @param {Object} jsonApiErrors
  @param {Object} options
  @return {Object}
*/

export default function prepareResponseErrors(jsonApiErrors, options) {
  // Instead of passing along rails-style errors we now get a JSON API
  // errors object that we'll temporarily munge into the old style.
  // http://emberjs.com/blog/2015/06/18/ember-data-1-13-released.html#toc_new-errors-api
  // has more detail, as well as http://jsonapi.org/format/#error-objects
  let legacyErrors = createLegacyErrors(jsonApiErrors);

  let errorsObject = deepJoinArrays(deepCamelizeKeys(legacyErrors));

  if (options && options.includeNames) {
    let humanize = options.includeNames === 'humanize';

    Object.keys(errorsObject).forEach((key) =>{
      let keyName = formatKey(key, humanize);
      errorsObject[key] = `${keyName} ${errorsObject[key]}`;
    });
  }
  return errorsObject;
}
