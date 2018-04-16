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
import Participants from 'tahi/mixins/components/task-participants';

export default Ember.Component.extend(Participants, {
  store: Ember.inject.service(),
  to: 'overlay-drop-zone',
  searchingParticipant: false,
  searchingAssignable: false,
  /**
   *  Method called after out animation is complete.
   *  This should be set to an action.
   *  This method is passed to `overlay-animate`
   *
   *  @method outAnimationComplete
   *  @required
  **/
  outAnimationComplete: null,

  /**
   *  Toggle insertion of overlay into DOM
   *
   *  @property visible
   *  @type Boolean
   *  @default false
   *  @required
  **/
  visible: false,

  assignable_users_url: Ember.computed('task', function() {
    return `/api/filtered_users/assignable_users/${this.get('task.id')}`;
  }),

  init() {
    this._super(...arguments);
    Ember.assert(
      'You must provide an outAnimationComplete action to OverlayTaskComponent',
      !Ember.isEmpty(this.get('outAnimationComplete'))
    );
  },

  actions: {
    postComment(body) {
      return this.get('store').createRecord('comment', {
        commenter: this.currentUser,
        task: this.get('task'),
        body: body,
        createdAt: new Date()
      }).save();
    },

    searchStarted() {
      this.set('searchingParticipant', true);
    },

    searchStartedAssignable() {
      this.set('searchingAssignable', true);
    },

    searchFinished() {
      this.set('searchingParticipant', false);
    },

    searchFinishedAssignable() {
      this.set('searchingAssignable', false);
    }

  }
});
