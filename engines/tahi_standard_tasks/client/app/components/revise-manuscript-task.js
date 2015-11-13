import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';

export default TaskComponent.extend({
  previousDecisions: Ember.computed('task.paper.decisions.[]', function() {
    return this.get('task.paper.decisions')
               .sortBy('revisionNumber').reverse().slice(2);
  }),

  latestDecision: Ember.computed('previousDecisions', function() {
    return this.get('task.paper.decisions')
               .sortBy('revisionNumber').reverse()[1];
  }),

  editingAuthorResponse: false,

  actions: {
    saveAuthorResponse() {
      this.get('latestDecision').save().then(()=> {
        this.set('editingAuthorResponse', false);
      });
    },

    editAuthorResponse() {
      return this.set('editingAuthorResponse', true);
    }
  }
});
