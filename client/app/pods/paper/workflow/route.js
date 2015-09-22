import Ember from 'ember';
import AuthorizedRoute from 'tahi/routes/authorized';
import Utils from 'tahi/services/utils';

export default AuthorizedRoute.extend({
  cardOverlayService: Ember.inject.service('card-overlay'),

  afterModel(paper) {
    // We need tasks for this view, but we'll access them via phases;
    // fetching tasks *then* phases reduces the total number of requests.
    return Ember.RSVP.all([paper.get('tasks'), paper.get('phases')]);
  },

  actions: {
    chooseNewCardTypeOverlay(phase) {
      let chooseNewCardTypeOverlay = this.controllerFor('overlays/chooseNewCardType');
      chooseNewCardTypeOverlay.set('phase', phase);

      this.store.find('adminJournal', phase.get('paper.journal.id')).then(function(adminJournal) {
        chooseNewCardTypeOverlay.set('journalTaskTypes', adminJournal.get('journalTaskTypes'));
      });

      this.send('openOverlay', {
        template: 'overlays/chooseNewCardType',
        controller: chooseNewCardTypeOverlay
      });
    },

    viewCard(task, queryParams) {
      this.get('cardOverlayService').setProperties({
        previousRouteOptions: ['paper.workflow', this.modelFor('paper')],
        overlayBackground: 'paper/workflow'
      });

      if($.isEmptyObject(queryParams)) {
        queryParams = { queryParams: {} };
      }

      this.transitionTo('paper.task', this.modelFor('paper'), task.id, queryParams);
    },

    addTaskType(phase, taskType) {
      if (!taskType) { return; }
      let unNamespacedKind = Utils.deNamespaceTaskType(taskType.get('kind'));

      this.store.createRecord(unNamespacedKind, {
        phase: phase,
        role: taskType.get('role'),
        type: taskType.get('kind'),
        paper: this.modelFor('paper'),
        title: taskType.get('title')
      }).save().then((newTask)=> {
        this.send('viewCard', newTask, {
          queryParams: { isNewTask: true }
        });
      });
    },

    showDeleteConfirm(task) {
      this.send('openOverlay', {
        template: 'overlays/card-delete',
        controller: 'overlays/card-delete',
        model: task
      });
    }
  }
});
