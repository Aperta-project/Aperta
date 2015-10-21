import Ember from 'ember';
import Utils from 'tahi/services/utils';

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
    },

    addTask(phase, taskType) {
      if (!taskType) { return; }
      let unNamespacedKind = Utils.deNamespaceTaskType(taskType.get('kind'));

      this.store.createRecord(unNamespacedKind, {
        phase: phase,
        role: taskType.get('role'),
        type: taskType.get('kind'),
        paper: this.modelFor('paper'),
        title: taskType.get('title')
      }).save().then(() => {
        this.send('closeModal');
      });
    },
  }
});
