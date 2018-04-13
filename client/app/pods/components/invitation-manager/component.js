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
import { eligibleUsersPath } from 'tahi/utils/api-path-helpers';
import { task as concurrencyTask } from 'ember-concurrency';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

const {
  computed,
  isEmpty
} = Ember;

const taskValidations = {
  'userEmail': ['email']
};

export default Ember.Component.extend(ValidationErrorsMixin, {
  init() {
    this._super(...arguments);
    this.set('dueIn', this.get('defaultDueIn'));
  },
  classNameBindings: ['errorMessage:errored'],
  store: Ember.inject.service(),
  restless: Ember.inject.service(),

  // external props
  replaceTargetName: '', // used in template replacements
  endpoint: '', // eligible users endpoint
  placeholder: '', // auto suggest placeholder
  groupByDecision: false,

  //internal stuff
  activeInvitation: null,
  activeInvitationState: 'closed', // 'closed', 'show', 'edit'
  composedInvitation: null,
  selectedUser: null,
  autoSuggestSelectedText: null,

  isEditingInvitation: computed('activeInvitation', 'activeInvitationState', function() {
    return this.get('activeInvitation') && this.get('activeInvitationState') === 'edit';
  }),

  errorMessage: computed('pendingInvitation.errors.email.firstObject.message', 'emailErrorMessage', function(){
    return (this.get('pendingInvitation.errors.email.firstObject.message') || this.get('emailErrorMessage'));
  }),

  disableButton: computed('errorMessage', 'selectedUser', function(){
    return (isEmpty(this.get('selectedUser')) || this.get('errorMessage')) ;
  }),

  validations: taskValidations,

  validateData() {
    this.set('emailErrorMessage', '');

    this.validate('userEmail', this.get('selectedUser.email'));
    const taskErrors = this.validationErrorsPresent();
    if(taskErrors) {
      this.set('emailErrorMessage', 'Please enter a valid email address');
    }

    return !taskErrors;
  },


  // note that both of these eventually alias to the paper's decisions
  decisions: computed.alias('task.decisions'),
  draftDecision: computed.alias('task.paper.draftDecision'),

  invitations: computed.alias('task.invitations'),

  inviteeRole: computed.reads('task.inviteeRole'),

  defaultDueIn: computed.reads('task.paper.reviewDurationPeriod'),

  loadDecisions: concurrencyTask(function * () {
    return yield this.get('task.decisions');
  }),

  autoSuggestSourceUrl: computed('task.id', 'endpoint', function(){
    return eligibleUsersPath(this.get('task.id'), this.get('endpoint'));
  }),

  parseUserSearchResponse(response) {
    return response.users;
  },

  displayUserSelected(user) {
    return user.full_name + ' <' + user.email + '>';
  },

  createInvitation: concurrencyTask(function * (props) {
    let invitation = this.get('store').createRecord('invitation', props);

    this.set('pendingInvitation', invitation);
    try {
      yield invitation.save();

      this.setProperties({
        selectedUser: null,
        pendingInvitation: null,
        autoSuggestSelectedText: null,
        dueIn: this.get('defaultDueIn')
      });
    } catch(error) {
      // In order to properly throw an ajax error (which allows ember-data
      // to do its thing) we have to wrap the ajax request in a try-catch block
    }
  }),

  persistedInvitations: computed('invitations.@each.isNew', function() {
    const invitations = this.get('invitations');
    return invitations.rejectBy('isNew');
  }),

  draftDecisionInvitations: computed(
    'draftDecision.invitations.@each.inviteeRole', function() {
      const type = this.get('inviteeRole');
      if (this.get('draftDecision.invitations')) {
        return this.get('draftDecision.invitations')
                    .filterBy('inviteeRole', type);
      }
    }
  ),

  previousDecisions: computed.alias('task.paper.previousDecisions'),

  decisionSorting: ['id:desc'],

  sortedPreviousDecisions: computed.sort('previousDecisions', 'decisionSorting'),

  actions: {
    cancelAction() {
      this.set('selectedUser', null);
      this.set('activeInvitation', null);
    },

    changePosition(newPosition, invitation) {
      this.get('changePosition').perform(newPosition, invitation);
    },

    createInvitation() {
      if (this.get('disableButton')) { return; }

      this.get('createInvitation').perform({
        dueIn: this.get('dueIn'),
        task: this.get('task'),
        email: this.get('selectedUser.email')
      });
    },

    // auto-suggest action
    didSelectUser(selectedUser) {
      this.set('emailErrorMessage', '');
      this.set('selectedUser', selectedUser);
    },

    saveInvite(invitation) {
      this.set('composedInvitation', null);
      return invitation.save();
    },

    destroyInvite(invitation) {
      invitation.destroyRecord();
    },

    toggleActiveInvitation(invitation, rowState) {
      this.set('activeInvitation', invitation);
      this.set('activeInvitationState', rowState);
    },

    // auto-suggest action
    inputChanged(val) {
      this.set('autoSuggestSelectedText', val);
      if(isEmpty(val)) {
        this.set('selectedUser', null);
        return;
      }

      this.set('selectedUser', {
        email: val
      });

      this.validate('userEmail', this.get('selectedUser.email'));
      const taskErrors = this.validationErrorsPresent();
      if(!taskErrors)
        this.set('emailErrorMessage', '');
    },
    focusOut(){
      this.validateData();
    }
  }
});
