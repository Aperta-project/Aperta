import AuthorizedRoute from 'tahi/routes/authorized';

export default AuthorizedRoute.extend({
  channelName: null,

  model(params) {
    return this.store.query('paper', { shortDoi: params.paper_shortDoi })
    .then((results) => {
      return results.get('firstObject');
    });
  },

  serialize(model) {
    return { paper_shortDoi: model.get('shortDoi') };
  },

  setupController(controller, model) {
    this._super(...arguments);
    this.setupPusher(model);
    model.get('commentLooks');
  },

  redirect(model, transition) {
    if (!transition.intent.url) {
      return;
    }
    var url = transition.intent.url.replace(`/papers/${model.get('id')}/`, `/papers/${model.get('shortDoi')}/`);
    if (url !== transition.intent.url) {
      this.transitionTo(url);
    }
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
