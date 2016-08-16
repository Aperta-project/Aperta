import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

const {
  Component,
  computed,
  computed: { alias, and, equal, not }
} = Ember;

export default Component.extend({
  classNameBindings: [':invitation-item', 'invitationStateClass', 'uiStateClass'],

  propTypes: {
    invitation: PropTypes.EmberObject.isRequired,
    destroyAction: PropTypes.func.isRequired
  },

  allowAttachments: true,

  invitee: alias('invitation.invitee'),
  displayDestroy: not('invitation.accepted'),
  displayEdit: and('invitation.pending', 'editAction', 'notClosedState'),
  displaySend: and('invitation.pending', 'editState'),

  detailState: 'closed',
  closedState: equal('detailState', 'closed'),
  editState: equal('detailState', 'edit'),
  notClosedState: not('closedState'),
  uiStateClass: computed('detailState', function() {
    return 'invitation-item--' + this.get('detailState');
  }),
  invitationStateClass: computed('invitation.state', function() {
    return 'invitation-state--' + this.get('invitation.state');
  }),

  actions: {
    editInvitation() {
      this.set('detailState', 'edit');
    },

    toggleDetails(invitation) {
      if (this.get('detailState') === 'closed') {
        invitation.fetchDetails().then(() => {
          this.set('detailState', 'show');
        });

        return;
      }

      this.set('detailState', 'closed');
    },

    cancelEdit(invitation) {
      invitation.rollbackAttributes();
      this.set('detailState', 'show');
    },

    save(invitation) {
      invitation.save().then(() => {
        this.set('detailState', 'show');
      });
    }
  }
});
