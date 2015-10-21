import Ember from 'ember';

export default Ember.Route.extend({

  model(params) {
    return this.store.find('phase', params.phase_id);
  },

  setupController: function (controller, model) {
    this._super(controller, model);
    this.store.find('adminJournal', model.get('paper.journal.id')).then(function(adminJournal) {
      controller.set('journalTaskTypes', adminJournal.get('journalTaskTypes'));
    });
  },

  actions: {

    closeModal: function() {
      this.transitionTo('paper.workflow', this.modelFor('paper'));
    }
  }
});
