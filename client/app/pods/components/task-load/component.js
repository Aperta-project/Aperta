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
    const store = this.container.lookup('store:main');
    const task = this.get('task');

    // Note: task find
    // We were calling `task.reload()` but this caused issues
    // when the task was in an invalid error state

    Ember.RSVP.all([
      task.get('nestedQuestions'),
      task.get('nestedQuestionAnswers'),
      task.get('participations'),
      store.find('task', task.get('id')) // see "NOTE: task find"
    ]).then(()=> {
      this.set('dataLoading', false);
    });
  }
});
