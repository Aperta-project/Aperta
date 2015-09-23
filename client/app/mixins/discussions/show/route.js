import Ember from 'ember';
import DiscussionsRoutePathsMixin from 'tahi/mixins/discussions/route-paths';

export default Ember.Mixin.create(DiscussionsRoutePathsMixin, {
  channelName: null,

  model(params) {
    return this.store.find('discussion-topic', params.topic_id);
  },

  afterModel(model) {
    this.channelName = 'private-discussiontopic@' + model.get('id');
    console.log("HI I AM wiring", this.channelName);
    this.get('pusher').wire(this, this.channelName, ['created', 'updated']);
  },

  deactivate() {
    this.get('pusher').unwire(this, this.channelName);
  },

  setupController(controller, model) {
    this._super(controller, model);
    model.reload();
  },

  _pusherEventsId() {
    // needed for the `wire` and `unwire` method to think we have
    // `ember-pusher/bindings` mixed in
    return this.toString();
  }
});
