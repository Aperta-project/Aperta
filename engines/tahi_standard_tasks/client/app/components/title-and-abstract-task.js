import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';

export default TaskComponent.extend({
  paperNotEditable: Ember.computed.not('task.paper.editable'),
  isNotEditable: Ember.computed('task.completed', 'paperNotEditable', function () {
    return this.get('task.completed') || this.get('paperNotEditable');
  }),

  actions: {
    titleChanged(contents) {
      this.set('task.paperTitle', contents);
    },

    abstractChanged(contents) {
      this.set('task.paperAbstract', contents);
    },

    focusOut() {
      return this.get('task').save();
    }
  }
});
