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
import { task as concurrencyTask } from 'ember-concurrency';

let errorText = 'There was a problem saving your invitation. Please refresh.';

export default Ember.Component.extend({
  flash: Ember.inject.service(),

  linkedInvitations: Ember.computed.filter('invitations.@each.primary', function(inv) {
    return inv.get('alternates.length');
  }),

  positionSort: ['position:asc'],
  sortedInvitations: Ember.computed.sort('invitations', 'positionSort'),

  invitationsInFlight: Ember.computed('invitations.@each.isSaving', function() {
    return this.get('invitations').isAny('isSaving');
  }),

  changePosition: concurrencyTask(function * (newPosition, invitation) {
    try {
      return yield invitation.changePosition(newPosition);
    } catch (e) {
      this.get('flash').displayRouteLevelMessage('error', errorText);
    }
  }).drop(),

  invitationIsExpanded: Ember.computed('activeInvitationState', function() {
    const state = this.get('activeInvitationState');
    return (state === 'show' || state === 'edit');
  }),

  actions: {
    changePosition(newPosition, invitation) {

      let sorted = this.get('sortedInvitations');

      sorted.removeObject(invitation);
      sorted.insertAt(newPosition - 1, invitation);
      this.get('changePosition').perform(newPosition, invitation);
    },

    displayError() {
      this.get('flash').displayRouteLevelMessage('error', errorText);
    }
  }
});
