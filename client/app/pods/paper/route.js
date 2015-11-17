import Ember from 'ember';
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
  }
});
