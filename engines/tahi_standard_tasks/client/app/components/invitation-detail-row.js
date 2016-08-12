import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  tagName: '',
  propTypes: {
    invitation: PropTypes.EmberObject.isRequired,
    destroyAction: PropTypes.func.isRequired
  },

  invitee: Ember.computed.alias('invitation.invitee'),
  displayDestroy: Ember.computed.not('invitation.accepted'),
  displayEdit: Ember.computed.and('invitation.pending', 'showDetails', 'editAction'),

  showDetails: false,
  detailState: 'show',

  actions: {
    editInvitation() {
      this.set('detailState', 'edit');
    },

    toggleDetails(invitation) {
      if (!this.get('showDetails')) {
        invitation.fetchDetails().then(() => {
          this.set('showDetails', true);
        });
      } else {
        if (this.get('detailState') === 'show') {
          this.set('showDetails', false);
        }
      }
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
