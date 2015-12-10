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
  dataLoading: false,

  init() {
    this._super(...arguments);
    this.set('dataLoading', true);
    const task = this.get('task');

    Ember.RSVP.all([
      task.get('nestedQuestions'),
      task.get('nestedQuestionAnswers'),
      task.get('participations'),
      task.reload()
    ]).then(()=> {
      this.set('dataLoading', false);
    });
  }
});
