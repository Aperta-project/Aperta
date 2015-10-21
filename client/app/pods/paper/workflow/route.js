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

      this.transitionTo('paper.workflow.tasks.new', this.modelFor('paper'), phase);
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
