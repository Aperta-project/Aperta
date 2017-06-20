import Ember from 'ember';

export default Ember.Component.extend({
  workflows: [],
  workflowSort: ['paperType:asc', 'journal.name:asc'],
  sortedWorkflows: Ember.computed.sort('workflows', 'workflowSort'),
  journal: null,

  routing: Ember.inject.service('-routing'),
  classNames: ['admin-workflow-catalogue'],
  canDestroyWorkflows:
    Ember.computed.gt('workflows.length', 1),

  actions: {
    editWorkflow(journal, workflow) {
      this.get('routing')
        .transitionTo(
          'admin.journal.manuscript_manager_template.edit',
          [journal, workflow]);
    },

    destroyWorkflow(workflow) {
      if (this.get('canDestroyWorkflows')) {
        return workflow.destroyRecord();
      }
    }
  }
});
