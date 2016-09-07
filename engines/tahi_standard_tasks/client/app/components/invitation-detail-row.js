import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

const {
  Component,
  computed,
  computed: { equal, reads, and, or },
  inject: { service }
} = Ember;

/*
 * UI States: closed, show, edit
 *
 */

export default Component.extend({
  classNameBindings: [':invitation-item', 'invitationStateClass',
    'uiStateClass', 'alternate:invitation-item--alternate'],

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

  sendButtonClass: computed('sendDisabled', function() {
    return this.get('sendDisabled') ? 'invitation-item-action--disabled' : '';
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

  displayRescindButton: or('invitation.invited', 'invitation.accepted'),

  uiState: computed('invitation', 'activeInvitation', 'activeInvitationState', function() {
    if (this.get('invitation') !== this.get('activeInvitation')) {
      return 'closed';
    } else {
      return this.get('activeInvitationState');
    }
  }),

  closedState: equal('uiState', 'closed'),
  editState: equal('uiState', 'edit'),

  actions: {
    toggleDetails() {
      if (this.get('uiState') === 'closed') {
        this.get('setRowState')('show');
      } else {
        this.get('setRowState')('closed');
      }
    },

    primarySelected(primary) {
      this.set('potentialPrimary', primary);
    },

    editInvitation(invitation) {
      this.setProperties({
        invitationBodyStateBeforeEdit: invitation.get('body')
      });
      this.get('setRowState')('edit');
    },

    cancelEdit(invitation) {
      this.set('potentialPrimary', null);
      if (this.get('deleteOnCancel') && invitation.get('pending')) {
        invitation.destroyRecord();
      } else {
        invitation.rollbackAttributes();
        invitation.set('body', this.get('invitationBodyStateBeforeEdit'));
        invitation.save();
        this.get('setRowState')('show');
      }
    },

    rescindInvitation(invitation) {
      invitation.rescind();
    },

    destroyInvitation(invitation) {
      if (invitation.get('pending')) {
        invitation.destroyRecord();
      }
    },

    saveDuringType(invitation) {
      Ember.run.debounce(invitation, 'save', 500);
    },

    save(invitation) {
      const potentialPrimary = this.get('potentialPrimary');

      if(potentialPrimary) {
        invitation.set('primary', potentialPrimary);
      }

      invitation.save().then( ()=>{
        this.get('setRowState')('show');
      });
    },

    destroyInvitation(invitation) {
      if (invitation.get('pending')) {
        invitation.destroyRecord();
      }
    },

    sendInvitation(invitation) {
      if(this.get('sendDisabled')) { return; }
      invitation.send();
    }
  }
});
