import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';

const { computed, on } = Ember;

export default TaskComponent.extend({
  latestDecision: computed('previousDecisions', function() {
    return this.get('task.paper.decisions')
               .sortBy('revisionNumber').reverse()[1];
  }),

  previousDecisions: computed('task.paper.decisions.[]', function() {
    return this.get('task.paper.decisions')
               .sortBy('revisionNumber').reverse().slice(2);
  }),

  editingAuthorResponse: false,

  _editIfResponseIsEmpty: on('didInsertElement', function() {
    Ember.run.scheduleOnce('afterRender', ()=> {
      this.set(
        'editingAuthorResponse',
        Ember.isEmpty(this.get('latestDecision.authorResponse'))
      );
    });
  }),

  actions: {
    saveAuthorResponse() {
      this.get('latestDecision').save().then(()=> {
        this.set('editingAuthorResponse', false);
      });
    },

    editAuthorResponse() {
      this.set('editingAuthorResponse', true);
    }
  }
});
