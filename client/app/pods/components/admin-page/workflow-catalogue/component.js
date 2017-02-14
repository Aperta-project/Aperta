import Ember from 'ember';

export default Ember.Component.extend({
  workflows: [],
  journal: null,

  routing: Ember.inject.service('-routing'),
  classNames: ['admin-workflow-catalogue'],

  actions: {
    editWorkflow(journal, workflow) {
      this.get('routing')
        .transitionTo(
          'admin.journal.manuscript_manager_template.edit',
          [journal, workflow]);
    }
  }
});
