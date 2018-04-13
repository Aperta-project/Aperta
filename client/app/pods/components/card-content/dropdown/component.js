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
  classNames: ['card-content', 'card-content-dropdown'],

  propTypes: {
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool,
    repetition: PropTypes.oneOfType([PropTypes.null, PropTypes.EmberObject]).isRequired,
    answer: PropTypes.EmberObject.isRequired
  },

  selectedValue: Ember.computed(
    'answer.value',
    'content.possibleValues',
    function() {
      return this.get('content.possibleValues').findBy(
        'value',
        this.get('answer.value')
      );
    }
  ),

  init() {
    this._super(...arguments);

    Ember.assert(
      `the content must define an array of possibleValues
      that contains at least one object with the shape { label, value } `,
      Ember.isPresent(this.get('content.possibleValues'))
    );
  },

  actions: {
    handleFocus(select) {
      select.actions.open();
    },

    toggleDropdown() {
      this.$('.ember-power-select-trigger').focus();
    },

    valueChanged(newVal) {
      let action = this.get('valueChanged');
      if (action) {
        action(Ember.get(newVal, 'value'));
      }
    }
  }
});
