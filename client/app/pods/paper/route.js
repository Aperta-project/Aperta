import RESTless from 'tahi/services/rest-less';
import Utils from 'tahi/services/utils';
import AuthorizedRoute from 'tahi/routes/authorized';

export default AuthorizedRoute.extend({
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
    let pusher = this.get('pusher');
    let userChannelName = `private-user@${ this.currentUser.get('id') }`;

    pusher.wire(this, this.channelName(model.get('id')), ['created', 'updated']);

    this.store.find('discussion-topic', {
      paper_id: model.get('id')
    }).then((topics) => {
      topics.forEach(this.subscribeToDiscussionTopic.bind(this));

      pusher.wire(this, userChannelName, ["discussion-participant-created"]);
    });
  },

  deactivate() {
    this.get('pusher').unwire(this, this.channelName(this.modelFor('paper').get('id')));
    let topics = this.controller.get('subscribedTopics');
    topics.forEach(this.unsubscribeFromDiscussionTopic.bind(this));
  },

  subscribeToDiscussionTopic(topic) {
    this.get('pusher').wire(this, this.topicChannelName(topic), ['created', 'updated']);
    this.controller.get('subscribedTopics').pushObject(topic);
  },

  unsubscribeFromDiscussionTopic(topic) {
    this.get('pusher').unwire(this, this.topicChannelName(topic));
    this.controller.get('subscribedTopics').removeObject(topic);
  },

  _pusherEventsId() {
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

      this.send('openOverlay', {
        template: 'overlays/showCollaborators',
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
      let discussionParticipant = payload.discussion_participant;
      this.store.findById('discussion-topic', discussionParticipant.discussion_topic_id).then((topic) => {
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
