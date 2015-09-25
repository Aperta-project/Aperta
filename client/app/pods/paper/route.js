import Ember from 'ember';
import Utils from 'tahi/services/utils';
import AuthorizedRoute from 'tahi/routes/authorized';

export default AuthorizedRoute.extend({
  restless: Ember.inject.service('restless'),

  model(params) {
    return this.store.fetchById('paper', params.paper_id);
  },

  setupController(controller, model) {
    model.get('commentLooks');
    this._super(controller, model);
  },

  channelName(id) {
    return 'private-paper@' + id;
  },

  topicChannelName(topic) {
    return 'private-discussion_topic@' + topic.get('id');
  },

  afterModel(model) {
    const pusher = this.get('pusher');
    const userChannelName = `private-user@${ this.currentUser.get('id') }`;
    const events = ['created', 'updated'];

    pusher.wire(this, this.channelName(model.get('id')), events);

    this.store.find('discussion-topic', {
      paper_id: model.get('id')
    }).then((topics) => {
      topics.forEach(this.subscribeToDiscussionTopic.bind(this));
      pusher.wire(this, userChannelName, ['discussion-participant-created']);
    });
  },

  deactivate() {
    const paperId = this.modelFor('paper').get('id');
    const channelName = this.channelName(paperId);

    this.get('pusher').unwire(this, channelName);
    const topics = this.controller.get('subscribedTopics');
    topics.forEach(this.unsubscribeFromDiscussionTopic.bind(this));
  },

  subscribeToDiscussionTopic(topic) {
    const events = ['created', 'updated'];
    const channelname = this.topicChannelName(topic);

    this.get('pusher').wire(this, channelname, events);
    this.controller.get('subscribedTopics').pushObject(topic);
  },

  unsubscribeFromDiscussionTopic(topic) {
    this.get('pusher').unwire(this, this.topicChannelName(topic));
    this.controller.get('subscribedTopics').removeObject(topic);
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
    },

    discussionParticipantCreated(payload) {
      const discussionParticipant = payload.discussion_participant;
      const id = discussionParticipant.discussion_topic_id;

      this.store.findById('discussion-topic', id).then((topic) => {
        if(topic.get('paperId') === this.modelFor('paper').get('id')) {
          this.subscribeToDiscussionTopic(topic);
        }
      });
    },

    discussionTopicCreated(topic) {
      this.subscribeToDiscussionTopic(topic);
    },

    discussionTopicDestroyed(topic) {
      this.unsubscribeFromDiscussionTopic(topic);
    }
  }
});
