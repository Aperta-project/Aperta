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

    addTaskType(phase, taskTypeList) {
      if (!taskTypeList) { return; }

      let promises = [];

      taskTypeList.forEach((task) => {
        let unNamespacedKind = Utils.deNamespaceTaskType(task.get('kind'));
        let newTaskPromise = this.store.createRecord(unNamespacedKind, {
          phase: phase,
          role: task.get('role'),
          type: task.get('kind'),
          paper: this.modelFor('paper'),
          title: task.get('title')
        }).save();

        promises.push(newTaskPromise);
      });

      Ember.RSVP.all(promises).then(() => {
        this.send('closeModal');
      });
    },
  }
});
