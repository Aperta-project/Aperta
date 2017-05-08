import Ember from 'ember';

export default Ember.Route.extend({
  notifications: Ember.inject.service(),
  storage: Ember.inject.service('discussions-storage'),
  channelName: null,

  model(params) {
    return this.store.findRecord('discussion-topic', params['discussion-topic_id']);
  },

  redirect(model) {
    var paperId = this.modelFor('discussions.paper').get('id');

    if (model.get('paperId') !== paperId) {
      this.transitionTo('discussions.paper.index');
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
    const discussionModel = this.modelFor('discussions.paper.show');
    controller.set('atMentionableStaffUsers', discussionModel.atMentionableStaffUsers);
    controller.set('validationErrors', {});
    this._super(controller, model);
    this._setupInProgressComment(controller, model);
    model.reload();
  },

  _setupInProgressComment(controller, model) {
    const comment = this.get('storage')
                        .getItem(model.get('id'));

    controller.set(
      'inProgressComment',
      (Ember.isEmpty(comment) ? '' : comment)
    );
  },

  _pusherEventsId() {
    // needed for the `wire` and `unwire` method to think we have
    // `ember-pusher/bindings` mixed in
    return this.toString();
  }
});
