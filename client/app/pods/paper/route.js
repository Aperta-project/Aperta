import Ember from 'ember';
import Utils from 'tahi/services/utils';
import AuthorizedRoute from 'tahi/routes/authorized';

export default AuthorizedRoute.extend({
  restless: Ember.inject.service('restless'),
  channelName: null,

  model(params) {
    return this.store.fetchById('paper', params.paper_id);
  },

  setupController(controller, model) {
    model.get('commentLooks');
    this._super(controller, model);
  },

  afterModel(model) {
    let pusher = this.get('pusher');
    this.channelName = 'private-paper@' + model.get('id');

    // This will bubble up to created and updated actions in the root
    // application route
    pusher.wire(this, this.channelName, ['created', 'updated', 'destroyed']);
  },

  deactivate() {
    this.get('pusher').unwire(this, this.channelName);
  },

  _pusherEventsId() {
    // needed for the `wire` and `unwire` method
    // to think we have `ember-pusher/bindings` mixed in
    return this.toString();
  },

  actions: {
    addContributors() {
      let controller     = this.controllerFor('overlays/showCollaborators');
      let collaborations = this.modelFor('paper').get('collaborations') || [];

      controller.setProperties({
        paper: this.modelFor('paper'),
        collaborations: collaborations,
        initialCollaborations: collaborations.slice(),
        allUsers: this.store.find('user')
      });

      this.send('openOverlay', {
        template: 'overlays/showCollaborators',
        controller: controller
      });
    },

    showActivity(type) {
      const paperId = this.modelFor('paper').get('id');
      const url = `/api/papers/${paperId}/activity/${type}`;
      const controller = this.controllerFor('overlays/activity');
      controller.set('isLoading', true);

      this.get('restless').get(url).then(function(data) {
        controller.setProperties({
          isLoading: false,
          model: Utils.deepCamelizeKeys(data.feeds)
        });
      });

      this.send('openOverlay', {
        template: 'overlays/activity',
        controller: controller
      });
    },

    showConfirmWithdrawOverlay() {
      let controller = this.controllerFor('overlays/paper-withdraw');
      controller.set('model', this.currentModel);

      this.send('openOverlay', {
        template: 'overlays/paper-withdraw',
        controller: 'overlays/paper-withdraw'
      });
    }
  }
});
