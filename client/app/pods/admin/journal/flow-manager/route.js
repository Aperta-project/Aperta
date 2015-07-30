import Ember from 'ember';

export default Ember.Route.extend({
  afterModel: function(role) {
    return this.store.find('flow', { role_id: role.get('id') });
  },

  setupController: function(controller, model) {
    controller.setProperties({
      model: model,
      commentLooks: this.store.all('commentLook'),
      journal: this.modelFor('admin.journal'),
      journalTaskTypes: this.store.all('journalTaskType')
    });
  },

  renderTemplate: function() {
    this._super();
    this.render('flow-manager-buttons', {
      outlet: 'controlBarButtons',
      template: 'journal'
    });
  },

  actions: {
    viewCard(task) {
      let paperId = task.get('paper.id');
      let redirectParams = ['admin.journal.flow_manager', this.modelFor('admin.journal'), this.modelFor('admin.journal.flow_manager')];
      this.controllerFor('application').get('overlayRedirect').pushObject(redirectParams);
      this.controllerFor('application').set('overlayBackground', 'admin.journal.flow_manager');
      this.transitionTo('paper.task', paperId, task.get('id'));
    }
  }
});
