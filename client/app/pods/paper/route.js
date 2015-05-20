import RESTless from 'tahi/services/rest-less';
import Utils from 'tahi/services/utils';
import AuthorizedRoute from 'tahi/routes/authorized';

export default AuthorizedRoute.extend({
  model(params) {
    return this.store.fetchById('paper', params.paper_id);
  },

  setupController: function(controller, model) {
    model.get('commentLooks');
    this._super(controller, model);
  },

  channelName: function(id) {
    return 'private-paper@' + id;
  },

  afterModel: function(model, transition) {
    this.get('pusher').wire(this, this.channelName(model.get('id')), ['created', 'updated']);
  },

  deactivate: function() {
    this.get('pusher').unwire(this, this.channelName(this.modelFor('paper').get('id')));
  }

  _pusherEventsId: function() {
    // needed for the `wire` and `unwire` method to think we have `ember-pusher/bindings` mixed in
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

      this.render('overlays/showCollaborators', {
        into: 'application',
        outlet: 'overlay',
        controller: controller
      });
    },

    showActivity(type) {
      let controller = this.controllerFor('overlays/activity');
      controller.set('isLoading', true);

      RESTless.get(`/api/papers/${this.modelFor('paper').get('id')}/activity/${type}`).then(function(data) {
        controller.setProperties({
          isLoading: false,
          model: Utils.deepCamelizeKeys(data.feeds)
        });
      });

      this.render('overlays/activity', {
        into: 'application',
        outlet: 'overlay',
        controller: controller
      });
    }
  }
});
