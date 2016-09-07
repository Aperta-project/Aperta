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
    save(invitation) {
      invitation.save().then(() => {
        this.get('closeAction')();
      });
    },
    cancel(invitation) {
      invitation.destroyRecord().then(() => {
        this.get('closeAction')();
      });
    }
  }
});
