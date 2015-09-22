import Ember from 'ember';
import AuthorizedRoute from 'tahi/routes/authorized';
import Utils from 'tahi/services/utils';

export default AuthorizedRoute.extend({
  cardOverlayService: Ember.inject.service('card-overlay'),

  afterModel(paper) {
    // TODO: No no. We should be able to remove or move this check to somewhere
    // that doesn't block rendering. We only do this now because all tasks are
    // loaded for all users. This will be changing in the future.
    // 
    // Ping manuscript_manager url for authorization
    return new Ember.RSVP.Promise(function(resolve, reject) {
      return Ember.$.ajax({
        method: 'GET',
        url: '/api/papers/' + paper.get('id') + '/manuscript_manager',
        success(json) { return Ember.run(null, resolve, json); },
        error(xhr)    { return Ember.run(null, reject, xhr); }
      });
    });
  },

  actions: {
    chooseNewCardTypeOverlay(phase) {
      let chooseNewCardTypeOverlay = this.controllerFor('overlays/chooseNewCardType');
      chooseNewCardTypeOverlay.set('phase', phase);

      this.store.findRecord('admin-journal', phase.get('paper.journal.id')).then(function(adminJournal) {
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
