import Ember from 'ember';

/**
 *  task-load ensures the task and other required data is loaded
 *  before rendering a child content. While data is loading, a loading
 *  partial is displayed.
 *
 *  @example
 *    {{#task-load task=task}}
 *      {{super-important-task task=task}}
 *    {{/task-load}}
 *
 *  @class TaskLoadComponent
 *  @extends Ember.Component
 *  @since 1.3.3
**/


export default Ember.Component.extend({
  store: Ember.inject.service(),
  taskLoad: null,

  init() {
    this._super(...arguments);
    const task = this.get('task');

    // Note: task find
    // We were calling `task.reload()` but this caused issues
    // when the task was in an invalid error state

    this.set('taskLoad', Ember.RSVP.all([
      task.get('nestedQuestions'),
      task.get('nestedQuestionAnswers'),
      task.get('participations'),
      this.get('store').findRecord('task', task.get('id')) // see "NOTE: task find"
    ]));
  }
});
