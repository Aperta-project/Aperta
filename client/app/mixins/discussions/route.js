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

import Ember from 'ember';
import DiscussionsRoutePathsMixin from 'tahi/mixins/discussions/route-paths';

export default Ember.Mixin.create(DiscussionsRoutePathsMixin,{
  subscribedTopics: [],
  popoutRoute: 'index',
  popoutDiscussionId: null,

  model() {
    const paper = this.modelFor('paper');
    return Ember.RSVP.hash({
      atMentionableStaffUsers: paper.atMentionableStaffUsers()
    });
  },

  activate() {
    this.set('popoutRoute', 'index');
    this.set('popoutDiscussionId', null);
  },

  actions: {
    popOutDiscussions() {
      let options = {
        discussionId: this.get('popoutDiscussionId'),
        path: 'discussions.paper.' + this.get('popoutRoute')
      };

      this.send('openDiscussionsPopout', options);
      this.send('hideDiscussions');
    },

    updatePopoutRoute(route) {
      this.set('popoutRoute', route);
    },

    updateDiscussionId(id) {
      this.set('popoutDiscussionId',id);
    },

    hideDiscussions() {
      this.transitionTo(this.get('topicsParentPath'));
    }
  }
});
