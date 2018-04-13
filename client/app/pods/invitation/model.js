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
import DS from 'ember-data';

let currentState = function(stateName) {
  return Ember.computed.equal('state', stateName);
};

export default DS.Model.extend({
  abstract: DS.attr('string'),
  actor: DS.belongsTo('user', { inverse: 'invitations' }),
  attachments: DS.hasMany('invitation-attachment'),
  body: DS.attr('string'),
  createdAt: DS.attr('date'),
  declineReason: DS.attr('string'),
  email: DS.attr('string'),
  information: DS.attr('string'),
  invitationType: DS.attr('string'),
  invitee: DS.belongsTo('user', { inverse: 'invitations' }),
  inviteeRole: DS.attr('string'),
  position: DS.attr('number'),
  primary: DS.belongsTo('invitation', { inverse: 'alternates', async: false }),
  alternates: DS.hasMany('invitation', { inverse: 'primary' }),
  reviewerSuggestions: DS.attr('string'),
  state: DS.attr('string'),
  task: DS.belongsTo('task', { polymorphic: true, async: true }),
  decision: DS.belongsTo('decision', {async: false}),
  title: DS.attr('string'),
  htmlSafeTitle: Ember.computed('title', function () {
    return Ember.String.htmlSafe(this.get('title'));
  }),
  reviewerReport: DS.belongsTo('reviewer_report', { async: true }),
  paperShortDoi: DS.attr('string'),
  journalName: DS.attr('string'),
  dueIn: DS.attr('number'),

  isAlternate: Ember.computed.notEmpty('primary'),
  isPrimary: Ember.computed.notEmpty('alternates'),

  canReposition: Ember.computed.notEmpty('validNewPositionsForInvitation'),

  paperType: DS.attr('string'),
  updatedAt: DS.attr('date'),
  invitedAt: DS.attr('date'),
  acceptedAt: DS.attr('date'),
  declinedAt: DS.attr('date'),
  rescindedAt: DS.attr('date'),

  pendingFeedback: false,

  restless: Ember.inject.service('restless'),

  pending: currentState('pending'),
  invited: currentState('invited'),
  accepted: currentState('accepted'),
  declined: currentState('declined'),
  rescinded: currentState('rescinded'),

  validNewPositionsForInvitation: DS.attr(), // will come in as an array of integers

  invitationFeedbackIsBlank: Ember.computed(
    'reviewerSuggestions',
    'declineReason',
    function() {
      return Ember.isBlank(this.get('reviewerSuggestions')) &&
        Ember.isBlank(this.get('declineReason'));
    }
  ),

  isInvitedOrAccepted: Ember.computed.or('invited', 'accepted'),

  isAcceptedByInvitee: Ember.computed.equal('actor.id', 'invitee.id'),

  needsUserUpdate: Ember.computed.or('invited', 'pendingFeedback'),

  academicEditor: Ember.computed.equal('inviteeRole', 'Academic Editor'),
  reviewer: Ember.computed.equal('inviteeRole', 'Reviewer'),

  setDeclined() {
    this.set('state', 'declined');
  },

  rescind() {
    return this.get('restless')
    .put(`/api/invitations/${this.get('id')}/rescind`)
    .then((data) => {
      this.store.pushPayload(data);
      return this;
    });
  },

  updatePrimary(primaryId) {
    return this.get('restless').putUpdate(this, '/update_primary', { primary_id: primaryId });
  },

  changePosition(newPosition) {
    return this.get('restless').putUpdate(this, '/update_position', { position: newPosition });
  },

  decline() {
    let data = {
      'invitation': {
        'decline_reason': this.get('declineReason') || '',
        'reviewer_suggestions': this.get('reviewerSuggestions') || ''
      }
    };

    return this.get('restless')
     .put(`/api/invitations/${this.get('id')}/decline`, data)
     .then(() => {
       this.feedbackSent();
       return this;
     });
  },

  invite() {
    return this.get('restless').putUpdate(this, '/send_invite');
  },

  feedbackSent() {
    this.set('pendingFeedback', false);
  },

  declineFeedback() {
    this.set('declineReason', null);
    this.set('reviewerSuggestions', null);
    this.set('pendingFeedback', false);
  },

  accept(data={}) {
    var decamelizedData = {};
    ['firstName', 'lastName'].forEach((key) => {
      decamelizedData[key.decamelize()] = data[key];
    });
    return this.get('restless')
    .put(`/api/invitations/${this.get('id')}/accept`, decamelizedData)
    .then((data) => {
      this.store.pushPayload(data);
      return this;
    });
  }
});
