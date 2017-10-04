import TaskComponent from 'tahi/pods/components/task-base/component';

export default TaskComponent.extend({
  contentRoot: Ember.computed.reads('task.cardVersion.contentRoot'),
  renderAsDualColumn: Ember.computed.alias('task.cardVersion.contentRoot.renderAsDualColumn'),

  actions: {
    toggleTaskCompletion() {
      this._super(...arguments);

      // show any errors that may have been temporarily hidden
      this.get('task.answers').forEach(answer => {
        answer.set('hideErrors', false);
      });
    }
  }
});
