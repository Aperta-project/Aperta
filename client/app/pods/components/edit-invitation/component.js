import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  propTypes: {
    invitation: PropTypes.EmberObject.isRequired,
    allowAttachments: PropTypes.bool
  },

  classNames: ['invitation-item', 'invitation-item--edit'],

  allowAttachments: false,
  invitee: Ember.computed.reads('invitation.invitee'),

  actions: {
    sendInvitation(invitation) {
      invitation.send().then(() => {
        this.get('closeAction')();
      });
    }
  }
});
