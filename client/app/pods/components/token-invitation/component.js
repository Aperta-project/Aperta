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

export default Ember.Component.extend({
  overlayVisible: true,
  declineDone: false,
  notPendingFeedback: Ember.computed.not('model.pendingFeedback'),
  notInvited: Ember.computed.not('model.invited'),
  inactive: Ember.computed.and('notInvited', 'notPendingFeedback'),
  invitations: Ember.computed('model', function(){
    return [this.get('model')];
  }),
  actions: {
    acceptInvitation() {
      window.location.href = `/invitations/${this.get('model.id')}/accept`;
    },
    declineInvitation(invitation) {
      return invitation.save().then(() => {
        this.toggleProperty('declineDone');
      });
    },
    hideInvitationsOverlay() {},
    saveInvitation(invitation){
      invitation.save();
    }
  }
});
