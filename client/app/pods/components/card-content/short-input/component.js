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
import ValidateTextInput from 'tahi/mixins/validate-text-input';
import QAIdent from 'tahi/mixins/components/qa-ident';

export default Ember.Component.extend(QAIdent, ValidateTextInput, {
  classNames: ['card-content', 'card-content-short-input'],
  attributeBindings: ['isRequired:required', 'aria-required'],
  'aria-required': Ember.computed.reads('isRequiredString'),
  classNameBindings: ['answer.shouldShowErrors:has-error'],

  propTypes: {
    answer: PropTypes.EmberObject.isRequired,
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool
  },

  //short-input renders a standard {{input}} component, which doesn't bind aria attributes
  didInsertElement() {
    if (this.get('content.isRequired') === true) {
      this.$('input').attr({'aria-required': 'true'});
    }
  },

  actions: {
    valueChanged(e) {
      // super to valueChanged in ValidateTextInput mixin. Pass it the field's value instead of an event
      this._super(e.target.value);
    },

    maybeHideError() {
      if (Ember.isBlank(this.get('answerProxy'))) {
        this.set('hideError', true);
      }
    }
  }
});
