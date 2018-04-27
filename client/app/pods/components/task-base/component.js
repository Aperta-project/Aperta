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
import { task as concurrencyTask } from 'ember-concurrency';

const {
  Component,
  computed: { alias, and, not },
  inject: { service },
  isEmpty
} = Ember;

export default Component.extend(ValidationErrorsMixin, {
  can: service(),
  store: service(),

  classNames: ['task'],
  classNameBindings: [
    'isNotEditable:read-only',
    'taskStateToggleable:user-can-make-editable'
  ],
  dataLoading: true,

  completedErrorText: 'Please fix all errors',

  /**
   * isOverlay is currently only used directly by the preprint opt out card
   * (which is a custom card).  It's picked up as a condition by an 'if' card content
   */
  isOverlay: false,

  init() {
    this._super(...arguments);
    this.set('editAbility', this.get('can').build('edit', this.get('task')));
  },
  isMetadataTask: alias('task.isMetadataTask'),
  isSubmissionTask: alias('task.isSubmissionTask'),
  isOnlyEditableIfPaperEditable: alias('task.isOnlyEditableIfPaperEditable'),

  isEditableDueToPermissions: alias('editAbility.can'),
  isEditableDueToTaskState: not('task.completedProxy'),

  isEditable: and(
    'isEditableDueToPermissions',
    'isEditableDueToTaskState'),
  isNotEditable: not('isEditable'),

  taskStateToggleable: alias('isEditableDueToPermissions'),
  mswordAllowed: Ember.computed.reads('task.paper.journal.mswordAllowed'),
  contentRoot: Ember.computed.reads('task.cardVersion.contentRoot'),

  saveTask: concurrencyTask(function * () {
    const currentSkipValidations = this.get('skipValidations');
    try {
      // if task is now incomplete skip validations
      yield this.get('task').save();
      this.clearAllValidationErrors();
    } catch (response) {
      this.displayValidationErrorsFromResponse(response);
      this.set('task.completed', false);
    } finally {
      this.set('skipValidations', this.get('currentSkipValidations'));
    }
  }).keepLatest(),

  save() {
    this.set('task.notReady', false);
    this.set('validationErrors.completed', '');
    if(!this.get('skipValidations')) {
      if(this.validateData) { this.validateData(); }

      if(this.validationErrorsPresent()) {
        this.set('task.completed', false);
        this.set('validationErrors.completed', this.get('completedErrorText'));
        return new Ember.RSVP.Promise((resolve) => resolve() );
      }
    }
    return this.get('saveTask').perform();
  },

  validateAll() {
    this.validateProperties();
    this.validateQuestions();
  },

  validateProperty(key) {
    this.validate(key, this.get(`task.${key}`));
  },

  validateProperties() {
    const validations = this.get('validations');
    if(isEmpty(validations)) { return; }

    _.keys(validations).forEach(key => {
      this.validateProperty(key);
    });
  },

  validateQuestion(key, value) {
    this.validate(key, value);
  },

  validateQuestions() {
    if(isEmpty(this.get('questionValidations'))) { return; }

    const nestedQuestionAnswers = this.get('task.nestedQuestions')
                                      .mapBy('answers');

    // NOTE: nested-questions.answers is hasMany relationship
    // so we need to flatten
    const answers = _.flatten(nestedQuestionAnswers.map(function(arr) {
      return _.compact( arr.map(function(a) {
        return a;
      }) );
    }) );

    answers.forEach(answer => {
      const key = answer.get('nestedQuestion.ident');
      const value = answer.get('value');

      this.validate(key, value);
    });
  },

  actions: {
    save()  {
      return this.save();
    },
    close() {
      this.attrs.close();
    },

    validateQuestion(key, value) {
      this.validateQuestion(key, value);
    },

    toggleTaskCompletion() {
      this.set('currentSkipValidations', this.get('skipValidations'));
      const isCompleted = this.toggleProperty('task.completed');

      // if task is now incomplete skip validations
      this.set('skipValidations', !isCompleted);

      this.save()
    }
  }
});
