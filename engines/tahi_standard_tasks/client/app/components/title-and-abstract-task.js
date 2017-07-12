import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';

export default TaskComponent.extend({
  isNotEditable: Ember.computed.alias('task.completed'),

  actions: {
    titleChanged(contents) {
      this.set('task.paperTitle', contents);
      this.get('task.debouncedSave').perform();
    },

    abstractChanged(contents) {
      this.set('task.paperAbstract', contents);
      this.get('task.debouncedSave').perform();
    }
  }
});
