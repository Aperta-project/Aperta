import Ember from 'ember';

export default Ember.Route.extend({
  cardOverlayService: Ember.inject.service('card-overlay'),

  model: function(params) {
    return this.store.find('role', params.role_id);
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
      let redirectParams = [
        'admin.journal.flow_manager',
        this.modelFor('admin.journal'),
        this.modelFor('admin.journal.flow_manager')
      ];

      this.get('cardOverlayService').setProperties({
        previousRouteOptions: redirectParams,
        overlayBackground: 'admin.journal.flow_manager'
      });

      this.transitionTo('paper.task', task.get('paper.id'), task.get('id'));
    }
  }
});
