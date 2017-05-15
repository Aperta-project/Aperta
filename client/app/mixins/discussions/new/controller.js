import DiscussionsRoutePathsMixin from 'tahi/mixins/discussions/route-paths';
import Ember from 'ember';
import { newDiscussionUsersPath } from 'tahi/utils/api-path-helpers';
import { task } from 'ember-concurrency';

const { Mixin, isEmpty } = Ember;

export default Mixin.create(DiscussionsRoutePathsMixin, {
  replyText: '',
  participants: [],
  searchingParticipant: false,

  topicCreation: task(function * (topic, replyText) {
    topic.set('initialDiscussionParticipantIDs', this.get('participants').mapBy('id'));
    yield topic.save();
    if(!isEmpty(replyText)) {
      yield this.createReply(replyText, topic);
    }

    this.transitionToRoute(this.get('topicsShowPath'), topic);
  }),

  createReply(replyText, topic) {
    return topic.get('discussionReplies').createRecord({
      discussionTopic: topic,
      replier: this.get('currentUser'),
      body: replyText
    }).save();
  },

  validateTitle() {
    if(this.titleIsValid()) {
      this.set('validationErrors.title', '');
    } else {
      this.set('validationErrors.title', 'This field is required');
    }
  },

  titleIsValid() {
    return !isEmpty(this.get('model.title'));
  },

  participantSearchUrl: Ember.computed('model.paperId', function() {
    return newDiscussionUsersPath(this.get('model.paperId'));
  }),

  actions: {
    validateTitle() {
      this.validateTitle();
    },

    save(topic, replyText) {
      this.validateTitle();
      if(!this.titleIsValid()) { return; }

      this.get('topicCreation').perform(topic, replyText);
    },

    searchStarted() {
      this.set('searchingParticipant', true);
    },

    searchFinished() {
      this.set('searchingParticipant', false);
    },

    addParticipant(selection) {
      const user = this.store.findOrPush('user', selection);
      this.get('participants').pushObject(user);
    },

    removeParticipant(userID) {
      const userToRemove = this.get('participants').findBy('id', userID);
      this.get('participants').removeObject(userToRemove);
    }
  }
});
