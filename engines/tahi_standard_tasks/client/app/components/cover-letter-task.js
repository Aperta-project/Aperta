import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';

export default TaskComponent.extend({
  letterBody: Ember.computed('task.body', function() {
    return this.get('task.body')[0];
  }),

  letterBodyIsEmpty: Ember.computed('letterBody', function() {
    return Ember.isEmpty(this.get('letterBody'));
  }),

  actions: {
    saveCoverLetter() {
      this.set('task.body', [this.get('letterBody')]);
      this.get('task').save();
    }
  }
});
