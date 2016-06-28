import TaskComponent from 'tahi/pods/components/task-base/component';

export default TaskComponent.extend({
  paperNotEditable: Ember.computed.not('task.paper.editable'),
  isNotEditable: Ember.computed.alias('task.completed'),

  actions: {
    focusOut() {
      return this.get('task').save();
    }
  }
});
