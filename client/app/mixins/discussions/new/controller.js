import Ember from 'ember';
import { task } from 'ember-concurrency';
import DiscussionsRoutePathsMixin from 'tahi/mixins/discussions/route-paths';

const { Mixin, isEmpty } = Ember;

export default Mixin.create(DiscussionsRoutePathsMixin, {
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
      if(isEmpty(this.get('model.title'))) {
        this.set('validationErrors.title', 'This field is required');
        return;
      }

      this.get('topicCreation').perform(topic, replyText);
    }
  }
});
