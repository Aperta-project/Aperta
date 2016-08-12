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

  actions: {
    editInvitation(invitation) {
      invitation.fetchDetails().then(() => {
        this.set('showDetails', true);
      });
    },
    showDetails(invitation) {
      invitation.fetchDetails().then(() => {
        this.set('showDetails', true);
      });
    }
  }
});
