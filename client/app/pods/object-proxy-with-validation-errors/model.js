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
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

const {
  assert,
  isEmpty,
} = Ember;

const ObjectProxy = Ember.Object.extend(ValidationErrorsMixin, {
  errorsPresent: false,
  validations: null,
  questionValidations: null,
  saveErrorText: 'Please fix the errors above',

  isNew: Ember.computed.reads('object.isNew'),

  init() {
    this._super(...arguments);

    const klass = 'ObjectProxyWithValidationErrors';
    const validationsEmpty = isEmpty(this.get('validations'));
    const questionValidationsEmpty = isEmpty(this.get('questionValidations'));

    assert(
      `the 'object' property must be set for #{klass}`,
      !isEmpty(this.get('object'))
    );

    assert(
      `the 'validations' or 'questionValidations' property must be set for ${klass}`,
      !validationsEmpty || !questionValidationsEmpty
    );
  },

  clearAllValidationErrors() {
    this.set('errorsPresent', false);
    this.set('validationErrors', {});
  },

  validateAll() {
    this.set('validationErrors.save', '');

    _.keys(this.get('validations')).forEach((key) => {
      this.validateProperty(key);
    });

    _.keys(this.get('questionValidations')).forEach((key) => {
      this.validateQuestion(key);
    });

    const errorsPresent = this.validationErrorsPresent();

    this.set('errorsPresent', errorsPresent);

    if(errorsPresent) {
      this.set('validationErrors.save', this.get('saveErrorText'));
    }
  },

  validateProperty(key) {
    this.validate(key, this.get(`object.${key}`));

    if(this.validationErrorsPresentForKey(key)) {
      this.set('errorsPresent', true);
    }
  },

  validateQuestion(ident) {
    const value = this.get('object').findQuestion(ident);
    this.validate(ident, value);

    if(this.validationErrorsPresentForKey(ident)) {
      this.set('errorsPresent', true);
    }
  }
});

ObjectProxy.reopenClass({
  errorsPresentInCollection(collection) {
    return !!(
      _.compact(collection.map(function(obj) {
        return obj.get('errorsPresent');
      }))
    ).length;
  }
});

export default ObjectProxy;
