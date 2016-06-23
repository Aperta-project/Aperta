import Ember from 'ember';
import DiscussionsRoutePathsMixin from 'tahi/mixins/discussions/route-paths';

export default Ember.Mixin.create(DiscussionsRoutePathsMixin, {
  notifications: Ember.inject.service(),
  channelName: null,

  model(params) {
    return this.store.findRecord('discussion-topic', params.topic_id);
  },

  redirect(model, transition) {
    var paperId = this.modelFor('paper').get('id');

    if (model.get('paperId') !== paperId) {
      this.transitionTo('paper.index.discussions');
    }
  },

  afterModel(model) {
    this.setModelChannel(model);
  },

  setModelChannel(model) {
    this.set('modelId', model.get('id'));
    const name = 'private-discussion_topic@' + model.get('id');

    this.set('channelName', name);
    this.get('pusher').wire(this, name, ['created', 'updated']);
  },

  deactivate() {
    this.get('pusher').unwire(this, this.channelName);

    this.get('notifications').remove({
      type: 'DiscussionTopic',
      id: this.get('modelId'),
      isParent: true
    });
  },

  setupController(controller, model) {
    let discussionRouteName = `paper.${this.get('subRouteName')}.discussions`;
    const discussionModel = this.modelFor(discussionRouteName);
    controller.set('atMentionableStaffUsers', discussionModel.atMentionableStaffUsers);
    this._super(controller, model);
    model.reload();
  },

  _pusherEventsId() {
    // needed for the `wire` and `unwire` method to think we have
    // `ember-pusher/bindings` mixed in
    return this.toString();
  }
});
