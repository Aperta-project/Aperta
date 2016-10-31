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
  classNameBindings: [':invitation-item', 'invitationStateClass', 'uiStateClass', 'disabled:invitation-item--disabled'],

  propTypes: {
    invitation: PropTypes.EmberObject.isRequired
  },

  allowAttachments: true,
  currentRound: computed.not('previousRound'),
  uiStateClass: computed('uiState', function() {
    return 'invitation-item--' + this.get('uiState');
  }),

  disabled: computed('uiState', function(){
    if ((this.get('activeInvitationState') === 'edit') && (this.get('activeInvitation') !== this.get('invitation'))) {
      return true;
    }
  }),

  invitationStateClass: computed('invitation.state', function() {
    return 'invitation-state--' + this.get('invitation.state');
  }),

  sendButtonClass: computed('sendDisabled', function() {
    return this.get('sendDisabled') ? 'invitation-item-action--disabled' : '';
  }),

  invitee: reads('invitation.invitee'),
  invitationBodyStateBeforeEdit: null,

  displayEditButton: computed('invitation.pending', 'closedState', 'currentRound', function() {
    return this.get('invitation.pending') && !this.get('closedState') && this.get('currentRound');
  }),

  displaySendButton: and('invitation.pending', 'currentRound'),

  displayDestroyButton: computed('invitation.pending', 'closedState', 'currentRound', function() {
    return this.get('invitation.pending') && !this.get('closedState') && this.get('currentRound');
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

    saveDuringType(invitation) {
      Ember.run.debounce(invitation, 'save', 500);
    },

    save(invitation) {
      const potentialPrimary = this.get('potentialPrimary');

      if(potentialPrimary) {
        if (potentialPrimary === 'cleared') {
          invitation.set('primary', null);
        } else {
          invitation.set('primary', potentialPrimary);
        }
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
