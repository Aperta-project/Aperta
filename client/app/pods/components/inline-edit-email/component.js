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
import formatDate from 'tahi/lib/aperta-moment';

export default Ember.Component.extend({
  editing: false,
  bodyPart: null,
  bodyPartType: Ember.computed.alias('bodyPart.type'),
  isSendable: Ember.computed.notEmpty('recipients'),
  showChooseReceivers: false,
  recipients: null,
  overlayParticipants: null,
  emailSentStates: null,
  lastSentAt: Ember.computed.reads('bodyPart.sent'),
  store: Ember.inject.service(),
  searchingParticipant: false,

  initRecipients: Ember.observer('showChooseReceivers', function() {
    if (!this.get('showChooseReceivers')) { return; }

    this.set('recipients', this.get('overlayParticipants').slice());
  }),

  keyForStates: Ember.computed.alias('bodyPart.subject'),

  showSentMessage: Ember.computed('keyForStates', 'emailSentStates.[]', function() {
    let key = this.get('keyForStates');
    return this.get('emailSentStates').includes(key);
  }),

  setSentState: function() {
    let key = this.get('keyForStates');
    return this.get('emailSentStates').addObject(key);
  },

  actions: {
    toggleChooseReceivers: function() {
      return this.toggleProperty('showChooseReceivers');
    },

    clearEmailSent: function() {
      return this.get('emailSentStates').removeObject(this.get('keyForStates'));

    },

    sendEmail: function() {
      var bodyPart, recipientIds;
      recipientIds = this.get('recipients').mapBy('id');
      bodyPart = this.get('bodyPart');
      this.set('bodyPart.sent', formatDate(Date.now(), 'long-date-day-ordinal'));
      this.get('sendEmail')({
        body: bodyPart.value,
        subject: bodyPart.subject,
        recipients: recipientIds
      });
      this.set('showChooseReceivers', false);
      return this.setSentState();

    },

    removeRecipient: function(recipientId) {
      let recipient = this.get('recipients').findBy('id', recipientId);
      return this.get('recipients').removeObject(recipient);
    },

    addRecipient: function(newRecipient) {
      const user = this.get('store').findOrPush('user', newRecipient);
      this.get('recipients').addObject(user);
    },

    searchStarted() {
      this.set('searchingParticipant', true);
    },

    searchFinished() {
      this.set('searchingParticipant', false);
    }
  }
});
