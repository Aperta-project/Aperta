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
import { task as concurrencyTask } from 'ember-concurrency';

/**
 *  task-load ensures the task and other required data is loaded
 *  before rendering child content. While the promise is unfulfilled,
 *  the task-load template yields to the parent to allow for the display
 *  of a loading spinner.
 *
 *  @example
 *    {{#task-load task=task}}
 *      {{super-important-task task=task}}
 *    {{else}}
 *      Loading...
 *    {{/task-load}}
 *
 *  @class TaskLoadComponent
 *  @extends Ember.Component
 *  @since 1.3.3
**/


export default Ember.Component.extend({
  store: Ember.inject.service(),

  task: null, //the aperta task

  taskLoad: concurrencyTask(function * () {
    const task = this.get('task');
    yield Ember.RSVP.all([
      task.get('nestedQuestions'),
      task.get('nestedQuestionAnswers'),
      task.get('participations'),
      task.get('repetitions'),
      task.get('answers'),
      this.get('store').findRecord(task._internalModel.modelName, task.get('id'), {reload: true}) // see "NOTE: task find"
    ]);
  })

});
