import Ember from 'ember';
import { task } from 'ember-concurrency';

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

  taskLoad: task(function * () {
    const task = this.get('task');
    return yield Ember.RSVP.all([
      task.get('nestedQuestions'),
      task.get('nestedQuestionAnswers'),
      task.get('participations'),
      this.get('store').findRecord('task', task.get('id'), {reload: true}) // see "NOTE: task find"
    ]);
  }),

});
