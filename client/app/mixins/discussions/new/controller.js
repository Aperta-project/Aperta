/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

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
