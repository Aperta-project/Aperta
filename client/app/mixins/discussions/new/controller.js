import Ember from 'ember';
import DiscussionsRoutePathsMixin from 'tahi/mixins/discussions/route-paths';
import { task } from 'ember-concurrency';

const { isEmpty } = Ember;

export default Ember.Mixin.create(DiscussionsRoutePathsMixin, {
  replyText: '',

  topicCreation: task(function * (topic, replyText) {
    yield topic.save();
    if(!isEmpty(replyText)) {
      yield this.createReply(replyText, topic);
    }

    this.transitionTo(this.get('topicsShowPath'), topic);
  }),

  createReply(replyText, topic) {
    return topic.get('discussionReplies').createRecord({
      discussionTopic: topic,
      replier: this.get('currentUser'),
      body: replyText
    }).save();
  },

  actions: {
    save(topic, replyText) {
      this.get('topicCreation').perform(topic, replyText);
    }
  }
});
