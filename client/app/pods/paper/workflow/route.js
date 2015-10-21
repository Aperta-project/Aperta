import Ember from 'ember';
import AuthorizedRoute from 'tahi/routes/authorized';
import Utils from 'tahi/services/utils';

export default AuthorizedRoute.extend({
  cardOverlayService: Ember.inject.service('card-overlay'),

  afterModel(paper) {
    // Ping manuscript_manager url for authorization.
    //
    // TODO: you shouldn't need to make a call to the server to decide
    // to render this page. Fix tasks#index to only return authorized
    // tasks, and then get this information off of user and paper
    // locally.
    let auth = new Ember.RSVP.Promise(function(resolve, reject) {
      return Ember.$.ajax({
        method: 'GET',
        url: '/api/papers/' + paper.get('id') + '/manuscript_manager',
        success(json) { return Ember.run(null, resolve, json); },
        error(xhr)    { return Ember.run(null, reject, xhr); }
      });
    });

    // We need tasks for this view, but we'll access them via phases;
    // fetching tasks *then* phases reduces the total number of requests.

    return Ember.RSVP.all([auth, paper.get('tasks'), paper.get('phases')]);
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

    addTaskType(phase, taskList) {
      if (!taskList) { return; }

      let promises = [];

      taskList.forEach((task) => {
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
        this.send('closeOverlay');
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
