import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';
import DragNDrop from 'tahi/services/drag-n-drop';

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

export default Component.extend(DragNDrop.DraggableMixin, {
  classNameBindings: [
    ':invitation-item',
    'invitationStateClass',
    'uiStateClass',
    'disabled:invitation-item--disabled', 'isAlternate:invitation-item--alternate'
  ],

  propTypes: {
    invitation: PropTypes.EmberObject.isRequired
  },

  isAlternate: computed.alias('invitation.primary'),

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

  model: computed.alias('invitation'),
  dragStart(e) {
    e.dataTransfer.effectAllowed = 'move';
    DragNDrop.dragItem = this.get('invitation');
    // REQUIRED for Firefox to let something drag
    // http://html5doctor.com/native-drag-and-drop
    e.dataTransfer.setData('Text', 'authorid');
  },

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

      this.get('setRowState')('show');
      this.get('saveInvite')(invitation).then(() => {
        let p;
        if(potentialPrimary) {
          if (potentialPrimary === 'cleared') {
            p = null;
          } else {
            p = potentialPrimary.get('id');
          }
          return invitation.updatePrimary(p);
        } else {
          return Ember.RSVP.resolve();
        }
      });
    },

    destroyInvitation(invitation) {
      if (invitation.get('pending')) {
        this.get('destroyInvite')(invitation);
      }
    },

    sendInvitation(invitation) {
      if(this.get('sendDisabled')) { return; }
      invitation.send();
    }
  }
});
