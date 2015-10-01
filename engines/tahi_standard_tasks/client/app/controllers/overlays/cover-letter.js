import TaskController from 'tahi/pods/paper/task/controller';
import Ember from 'ember';

export default TaskController.extend({
  letterBody: Ember.computed('model.body', function() {
    return this.get('model.body')[0];
  }),

  editingLetter: Ember.computed('model.body', function() {
    return this.get('model.body').length === 0;
  }),

  actions: {
    saveCoverLetter() {
      this.set('model.body', [this.get('letterBody')]);

      this.get('model').save().then(()=> {
        this.set('editingLetter', false);
      });
    },

    editCoverLetter() {
      this.set('editingLetter', true);
    }
  }
});
