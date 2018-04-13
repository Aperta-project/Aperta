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

export default Ember.Component.extend({
  classNames: ['attachment-snapshot'],
  classNameBindings: ['added', 'attachment1::removed'],
  attachment1: null,
  attachment2: null,

  added: Ember.computed('attachment2', function() {
    // gotta check if the whole thing was deleted, not just absent
    // because we're viewing a single version.
    return !this.get('attachment2') || _.isEmpty(this.get('attachment2'));
  }),

  fileHashChanged: Ember.computed(
    'attachment1.fileHash',
    'attachment2.fileHash',

    function() {
      var hash1 = this.get('attachment1.fileHash');
      var hash2 = this.get('attachment2.fileHash');
      return hash1 !== hash2;
    }
  )
});
