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
  invitation: null, // passed-in
  classNames: ['invitation-link-alternate'],
  filteredAlternates: Ember.computed.filter('invitations.@each.state', function(invitation) {
    // Reject suggested alternate if itself
    if (invitation === this.get('invitation')) { return false; }

    // Reject if already linked to a primary
    if (invitation.get('primary')) { return false; }

    return true;
  }),
  alternateCandidates: Ember.computed('filteredAlternates', function() {
    return this.get('filteredAlternates').map((inv) => {
      return this.inviteeDescription(inv);
    });
  }),
  selectedPrimary: Ember.computed('invitation.primary', function(){
    const inv = this.get('invitation.primary');
    if (inv) {
      return this.inviteeDescription(inv);
    } else {
      return null;
    }
  }),
  inviteeDescription(inv) {
    if (inv.get('invitee.name')) {
      return {
        id: inv,
        text: inv.get('invitee.name') + ' <' + inv.get('email') + '>'
      };
    } else {
      return {
        id: inv,
        text: inv.get('email')
      };
    }
  },

  actions: {
    selectionCleared() {
      this.get('primarySelected')('cleared');
    },
    selectionSelected(selection) {
      this.get('primarySelected')(selection.id);
    }
  }
});
