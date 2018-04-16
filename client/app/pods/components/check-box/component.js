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
  type: 'checkbox',
  classNameBindings: [':ember-checkbox', 'class', 'faIcon'],
  attributeBindings: 'type checked indeterminate disabled tabindex name autofocus form value content.isRequired:required aria-required'.w(),
  checked: false,
  disabled: false,
  indeterminate: false,
  'aria-required': Ember.computed.reads('content.isRequiredString'),

  _setupOnChange: Ember.on('init', function() {
    this.on('change', this, this._updateElementValue);
  }),

  _setupIndeterminate: Ember.on('didInsertElement', function() {
    this.get('element').indeterminate = !!this.get('indeterminate');
  }),

  _updateElementValue() {
    this.set('checked', this.$().prop('checked'));
  },

  change() {
    this.sendAction('action', this);
  }
});
