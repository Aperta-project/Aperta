import Ember from 'ember';
import { discussionUsersPath } from 'tahi/lib/api-path-helpers';
import DiscussionsRoutePathsMixin from 'tahi/mixins/discussions/route-paths';
import { task } from 'ember-concurrency';

// keep comment cache around for 30 days
const STORAGE_LENGTH = ((60*24)*30);

const {
  computed,
  Mixin,
  isEmpty,
  run
} = Ember;

export default Mixin.create(DiscussionsRoutePathsMixin, {
  inProgressComment: '',
  localStorageKey: computed('model.id', function() {
    return 'discussion:' + this.get('model.id');
  }),

  participants: computed('model.discussionParticipants.@each.user', function() {
    return this.get('model.discussionParticipants').mapBy('user');
  }),

  replySort: ['createdAt:desc'],
  sortedReplies: computed.sort('model.discussionReplies', 'replySort'),

  discussionParticipantUrl: computed('model.id', function() {
    return discussionUsersPath(this.get('model.id'));
  }),

  cacheComment(value) {
    window.lscache.setBucket('aperta');
    window.lscache.set(this.get('localStorageKey'), value, STORAGE_LENGTH);
  },

  clearCachedComment() {
    window.lscache.setBucket('aperta');
    window.lscache.remove(this.get('localStorageKey'));
  },

  replyCreation: task(function * (body) {
    yield this.store.createRecord('discussion-reply', {
      discussionTopic: this.get('model'),
      replier: this.get('currentUser'),
      body: body
    }).save();

    this.set('inProgressComment', '');
    this.clearCachedComment();
  }),

  actions: {
    commentDidChange(value) {
      this.cacheComment(value);
    },

    commentDidCancel() {
      this.clearCachedComment();
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

    saveNewParticipant(newParticipant, availableParticipants) {
      const participant = availableParticipants.findBy('id', newParticipant.id);
      const user = this.store.findOrPush('user', participant);

      this.store.createRecord('discussion-participant', {
        discussionTopic: this.get('model'),
        user: user,
      }).save();
    }
  }
});
