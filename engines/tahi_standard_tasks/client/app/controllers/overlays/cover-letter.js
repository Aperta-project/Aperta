import TaskController from 'tahi/pods/paper/task/controller';

export default TaskController.extend({

  letterBody: Ember.computed(function() {
    return this.model.get('body')[0];
  }),

  editingLetter: Ember.computed(function() {
    return this.model.get('body').length === 0;
  }),

  actions: {

    saveCoverLetter() {
      this.model.set('body', [this.get('letterBody')]);
      this.model.save().then(()=> {
        this.set('editingLetter', false);
      });
    },

    editCoverLetter() {
      this.set('editingLetter', true);
    }

  }
});
