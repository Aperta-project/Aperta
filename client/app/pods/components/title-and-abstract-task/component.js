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
import TaskComponent from 'tahi/pods/components/task-base/component';

const taskValidations = {
  'paperTitle': ['presence'],
  'paperAbstract': ['presence']
};

export default TaskComponent.extend({
  validations: taskValidations,

  validateData() {
    this.validateAll();
    const taskErrors = this.validationErrorsPresent();
    this.validate('paperTitle', this.get('task.paperTitle'));
    this.validate('paperAbstract', this.get('task.paperAbstract'));
    if(taskErrors) {
      this.set('validationErrors.completed', 'Please fix all errors');
    }
  },
  paperTitleError: Ember.computed('validationErrors.paperTitle', function(){
    if (this.get('validationErrors.paperTitle')){
      return [this.get('validationErrors.paperTitle')];
    }
  }),
  paperAbstractError: Ember.computed('validationErrors.paperAbstract', function(){
    if (this.get('validationErrors.paperAbstract')){
      return [this.get('validationErrors.paperAbstract')];
    }
  }),
  actions: {
    titleChanged(contents) {
      this.set('task.paperTitle', contents);
      this.get('task.debouncedSave').perform();
    },

    abstractChanged(contents) {
      this.set('task.paperAbstract', contents);
      this.get('task.debouncedSave').perform();
    },

    focusOut() {
      this.set('validationErrors.completed', '');
      this.validateData();
      if(!this.validationErrorsPresent()) {
        return this.get('task').save();
      }
    }
  }
});
