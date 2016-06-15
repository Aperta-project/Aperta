import AuthorizedRoute from 'tahi/routes/authorized';

export default AuthorizedRoute.extend({
  channelName: null,

  model(params) {
    return this.store.findRecord('paper', params.paper_id, { reload: true });
  },

  setupController(controller, model) {
    this._super(...arguments);
    this.setupPusher(model);
    model.get('commentLooks');
  },

  setupPusher(model) {
    let pusher = this.get('pusher');
    this.set('channelName', 'private-paper@' + model.get('id'));

    // This will bubble up to created and updated actions in the root
    // application route
    pusher.wire(this, this.channelName, ['created', 'updated', 'destroyed']);
  },

  deactivate() {
    this.get('pusher').unwire(this, this.get('channelName'));
  },

  _pusherEventsId() {
    // needed for the `wire` and `unwire` method
    // to think we have `ember-pusher/bindings` mixed in
    return this.toString();
  }
});
