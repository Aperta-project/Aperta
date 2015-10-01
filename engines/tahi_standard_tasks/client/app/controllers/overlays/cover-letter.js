import TaskController from 'tahi/pods/paper/task/controller';
import Ember from 'ember';

export default TaskController.extend({
  letterBody: Ember.computed('model.body', function() {
    return this.get('model.body')[0];
  }),

  emptyLetterBody: Ember.computed('model.body', function() {
    return Ember.isEmpty(this.get('model.body')[0]);
  }),

  actions: {
    saveCoverLetter() {
      this.set('model.body', [this.get('letterBody')]);
      this.get('model').save();
    }
  }
});
