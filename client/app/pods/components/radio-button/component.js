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
  tagName: 'input',
  type: 'radio',
  attributeBindings: ['name', 'type', 'value', 'checked:checked', 'disabled', 'content.isRequired:required', 'aria-required', 'data-test-selector:data-test-selector'],
  'aria-required': Ember.computed.reads('content.isRequiredString'),

  value: null,
  selection: null,

  init() {
    this._super(...arguments);
    Ember.assert(
      'You must pass a value property to the RadioButtonComponent',
      this.get('value') !== null && this.get('value') !== undefined
    );
    Ember.assert(
      'You must pass a selection property to the RadioButtonComponent',
      this.hasOwnProperty('selection')
    );
  },

  checked: Ember.computed('selection', 'value', function() {
    // When determining if the radio button should be selected or not,
    // coerce both the html radio button form element value and any
    // current answer to strings.  This is to protect against the case
    // where the answered value in the database is being returned as
    // a non-string datatype (e.g., `true` instead of "true").  At
    // the html level, the value will always be a string, so do a
    // string-to-string comparison here to ensure that the radio button
    // is properly selected or not.

    let s = this.get('selection');

    if (Ember.isEmpty(s)) {
      return false; // a prior answer does not exist
    } else {
      return s.toString() === this.get('value').toString(); // compare
    }
  }),

  change() {
    this.get('action')(this.get('value'));
  }
});
