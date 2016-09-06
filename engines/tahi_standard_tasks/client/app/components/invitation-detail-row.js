import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';
import { task, timeout } from 'ember-concurrency';

const {
  Component,
  computed,
  computed: { equal, reads, and },
  inject: { service }
} = Ember;

/*
 * UI States: closed, show, edit
 *
 * EventBus is for closing all rows when one is opened
 */

export default Component.extend({
  eventBus: service('event-bus'),
  classNameBindings: [':invitation-item', 'invitationStateClass', 'uiStateClass'],

  propTypes: {
    invitation: PropTypes.EmberObject.isRequired
  },

  allowAttachments: true,
  allowDestroy: true,
  allowSend: true,
  uiStateClass: computed('uiState', function() {
    return 'invitation-item--' + this.get('uiState');
  }),

  invitationStateClass: computed('invitation.state', function() {
    return 'invitation-state--' + this.get('invitation.state');
  }),

  invitee: reads('invitation.invitee'),
  invitationBodyStateBeforeEdit: null,

  displayEditButton: computed('invitation.pending', 'closedState', function() {
    return this.get('invitation.pending') && !this.get('closedState');
  }),

  displaySendButton: and('invitation.pending', 'allowSend'),

  displayDestroyButton: computed('invitation.pending', 'closedState', 'allowDestroy', function() {
    return this.get('allowDestroy') && this.get('invitation.pending') && !this.get('closedState');
  }),

  uiState: computed('invitation', 'activeInvitation', 'activeInvitationState', function() {
    if (this.get('invitation') !== this.get('activeInvitation')) {
      return 'closed';
    } else {
      return this.get('activeInvitationState');
    }
  }),

  closedState: equal('uiState', 'closed'),
  editState: equal('uiState', 'edit'),

  save: task(function * (invitation, delay=0) {
    yield timeout(delay);
    const promise = invitation.save();
    yield promise;
    this.get('templateSaved').perform();
    return promise;
  }).restartable(),

  templateSaved: task(function * () {
    yield timeout(3000);
  }).keepLatest(),

  actions: {
    toggleDetails() {
      if (this.get('uiState') === 'closed') {
        this.get('setRowState')('show');
      } else {
        this.get('setRowState')('closed');
      }
    },

    editInvitation(invitation) {
      this.setProperties({
        invitationBodyStateBeforeEdit: invitation.get('body')
      });
      this.get('setRowState')('edit');
    },

    cancelEdit(invitation) {
      invitation.rollbackAttributes();
      invitation.set('body', this.get('invitationBodyStateBeforeEdit'));
      invitation.save();
      this.get('setRowState')('show');
    },

    destroyInvitation(invitation) {
      if (invitation.get('pending')) {
        invitation.destroyRecord();
      }
    },

    saveDuringType(invitation) {
      this.get('save').perform(invitation, 1000);
    },

    save(invitation) {
      this.get('save').perform(invitation).then(() => {
        this.get('setRowState')('show');
      });
    },

    sendInvitation(invitation) {
      invitation.send();
    }
  }
});
