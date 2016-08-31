import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';
import { task, timeout } from 'ember-concurrency';

const {
  Component,
  computed,
  computed: { and, equal, not, reads }
} = Ember;

/*
 * UI States: closed, show, edit, delete
 */

export default Component.extend({
  classNameBindings: [':invitation-item', 'invitationStateClass', 'uiStateClass'],

  propTypes: {
    invitation: PropTypes.EmberObject.isRequired,
    destroyAction: PropTypes.func.isRequired
  },

  allowAttachments: true,

  invitee: reads('invitation.invitee'),

  displayDestroyButton: not('invitation.accepted'),
  displayEditButton: and('invitation.pending', 'notClosedState'),
  displaySendButton: reads('invitation.pending'),

  uiState: 'closed',
  closedState: equal('uiState', 'closed'),
  editState: equal('uiState', 'edit'),
  notClosedState: not('closedState'),

  uiStateClass: computed('uiState', function() {
    return 'invitation-item--' + this.get('uiState');
  }),

  invitationStateClass: computed('invitation.state', function() {
    return 'invitation-state--' + this.get('invitation.state');
  }),

  templateSaved: task(function * () {
    yield timeout(2000);
  }).keepLatest(),

  actions: {
    editInvitation() {
      this.set('uiState', 'edit');
    },

    toggleDetails(invitation) {
      if (this.get('uiState') === 'closed') {
        invitation.fetchDetails().then(() => {
          this.set('uiState', 'show');
        });

        return;
      }

      this.set('uiState', 'closed');
    },

    cancelEdit(invitation) {
      invitation.rollbackAttributes();
      this.set('uiState', 'show');
    },

    saveDuringType() {
      // TODO: save
      this.get('templateSaved').perform();
    },

    save(invitation) {
      invitation.save().then(() => {
        this.set('uiState', 'show');
      });
    },

    sendInvitation(invitation) {
      invitation.send();
    },

    confirmDeleteInvitation() {
      this.set('uiState', 'delete');
    }
  }
});
