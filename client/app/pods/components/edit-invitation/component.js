import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  propTypes: {
    invitation: PropTypes.EmberObject.isRequired,
    allowAttachments: PropTypes.bool
  },

  classNames: ['edit-invitation'],

  allowAttachments: false,

  actions: {
    sendInvitation(invitation) {
      invitation.send().then(() => {
        this.get('closeAction')();
      });
    }
  }
});
