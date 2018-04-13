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
import {PropTypes} from 'ember-prop-types';

export default Ember.Component.extend({
  propTypes: {
    type: PropTypes.string,
    name: PropTypes.string,
    value: PropTypes.string,
    required: PropTypes.oneOfType([PropTypes.null, PropTypes.bool]),
    placeholder: PropTypes.string,
    helpText: PropTypes.string,
    label: PropTypes.string,
    errors: PropTypes.oneOfType([PropTypes.null, PropTypes.EmberObject]),
    enter: PropTypes.func,
    autofocus: PropTypes.bool
  },

  classNames: ['labeled-input-with-errors'],

  errorsPresentOnField: Ember.computed('errors', function(){
    return this.get('errors') &&
           this.get('errors').has(this.get('name'));
  }),

  errorMessageOnField: Ember.computed('errorsPresentOnField', function(){
    if(this.get('errorsPresentOnField')){
      const fieldName = this.get('name');
      const errorsOnField = this.get('errors').errorsFor(fieldName);
      return errorsOnField.mapBy('message').join(', ');
    }
  }),

  inputClasses: Ember.computed('name', function() {
    return `form-control ${this.getWithDefault('name', '').dasherize()}`;
  }),

  labelClasses: Ember.computed('required', 'name', function() {
    return `${this.get('required') ? 'required' : ''} ${this.getWithDefault('name', '').dasherize()}`;
  }),

  actions: {
    // Called when user hits enter while focused on the input
    enter() {
      const passedInEnterAction = this.get('enter');
      if (passedInEnterAction) passedInEnterAction();
    }
  }
});
