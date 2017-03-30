import Ember from 'ember';
import { discussionUsersPath } from 'tahi/utils/api-path-helpers';
import DiscussionsRoutePathsMixin from 'tahi/mixins/discussions/route-paths';
import { task } from 'ember-concurrency';
import ENV from 'tahi/config/environment';

const {
  computed,
  Mixin,
  isEmpty
} = Ember;

export default Mixin.create(DiscussionsRoutePathsMixin, {
  storage: Ember.inject.service('discussions-storage'),
  inProgressComment: '',
  searchingParticipant: false,

  participants: computed('model.discussionParticipants.@each.user', function() {
    return this.get('model.discussionParticipants').mapBy('user');
  }),

  replySort: ['createdAt:desc'],
  sortedReplies: computed.sort('model.discussionReplies', 'replySort'),

  discussionParticipantUrl: computed('model.id', function() {
    return discussionUsersPath(this.get('model.id'));
  }),

  storeComment(value) {
    this.get('storage').setItem(this.get('model.id'), value);
  },

  clearStoredComment() {
    this.get('storage').removeItem(this.get('model.id'));
  },

  replyCreation: task(function * (body) {
    yield this.store.createRecord('discussion-reply', {
      discussionTopic: this.get('model'),
      replier: this.get('currentUser'),
      body: body
    }).save();

    this.set('inProgressComment', '');
    this.clearStoredComment();
  }),

  actions: {
    commentDidChange(value) {
      const delay = (Ember.testing || ENV.environment === 'test') ? 0 : 1000;
      Ember.run.debounce(this, this.storeComment, value, delay);
    },

    commentDidCancel() {
      this.clearStoredComment();
    },

    saveTopic() {
      if(isEmpty(this.get('model.title'))) {
        this.set('validationErrors.title', 'This field is required');
        return;
      }

      this.get('model').save();
      this.set('validationErrors', {});
    },

    postReply(body) {
      this.get('replyCreation').perform(body);
    },

    removeParticipantByUserId(userId) {
      this.get('model.discussionParticipants')
          .findBy('user.id', userId)
          .destroyRecord();
    },

    saveNewParticipant(newParticipantData) {
      this.store.createRecord('discussion-participant', {
        discussionTopic: this.get('model'),
        user: this.store.findOrPush('user', newParticipantData),
      }).save();
    },

    searchStarted() {
      this.set('searchingParticipant', true);
    },

    searchFinished() {
      this.set('searchingParticipant', false);
    }
  }
});
