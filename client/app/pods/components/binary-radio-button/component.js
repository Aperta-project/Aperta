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
const { computed } = Ember;

export default Ember.Component.extend({
  selection: null,
  index: null,
  yesValue: true,
  noValue: false,
  yesLabel: 'Yes',
  noLabel: 'No',

  idYes: computed('name', function() {
    return `${this.get('name')}-yes`;
  }),

  idNo: computed('name', function() {
    return `${this.get('name')}-no`;
  }),

  yesChecked: computed('selection', 'yesValue', function() {
    return Ember.isEqual(this.get('yesValue'), this.get('selection'));
  }),

  noChecked: computed('selection', 'noValue', function() {
    return Ember.isEqual(this.get('noValue'), this.get('selection'));
  }),

  actions: {
    selectYes() {
      this.set('selection', this.get('yesValue'));
      this.sendAction('yesAction');
    },

    selectNo() {
      this.set('selection', this.get('noValue'));
      this.sendAction('noAction');
    }
  }
});
