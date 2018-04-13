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
import { PropTypes } from 'ember-prop-types';
import QAIdent from 'tahi/mixins/components/qa-ident';

export default Ember.Component.extend(QAIdent, {
  classNames: ['card-content', 'card-content-radio'],
  tagName: 'fieldset',
  propTypes: {
    answer: PropTypes.EmberObject.isRequired,
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool,
    owner: PropTypes.EmberObject.isRequired,
    repetition: PropTypes.oneOfType([PropTypes.null, PropTypes.EmberObject]).isRequired,
    preview: PropTypes.bool
  },

  init() {
    this._super(...arguments);
    if(this.get('isText')) {
      Ember.assert(
        `the content must define an array of possibleValues
      that contains at least one object with the shape { label, value } `,
        Ember.isPresent(this.get('content.possibleValues'))
      );
    }
  },

  hasText: Ember.computed('content.text', function () {
    return Ember.isPresent(this.get('content.text'));
  }),

  trueLabel: Ember.computed('content.possibleValues', function () {
    return this.findLabelByValue('true') || 'Yes';
  }),

  falseLabel: Ember.computed('content.possibleValues', function () {
    return this.findLabelByValue('false') || 'No';
  }),

  findLabelByValue: function (match) {
    let list = this.get('content.possibleValues');
    if (list && list.length > 0) {
      let items = list.filter(each => each.value === match);
      if (items.length === 1) {
        return items[0].label;
      }
    }
    return null;
  },

  isText: Ember.computed('content.valueType', function() {
    return (this.get('content.valueType') === 'text');
  }),

  cardFormClass: Ember.computed('answer.hasErrors', function() {
    let hasErrors = this.get('answer.hasErrors');
    return hasErrors ? 'card-form-text-error' : 'card-form-text';
  }),

  actions: {
    valueChanged(newVal) {
      let action = this.get('valueChanged');
      if (action) {
        action(newVal);
      }
    }
  }
});
