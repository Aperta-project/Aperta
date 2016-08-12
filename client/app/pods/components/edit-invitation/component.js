import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  propTypes: {
    user: PropTypes.object.isRequired,
    invitation: PropTypes.EmberObject.isRequired
  },
  classNames: ['invite-editor-edit-invite'],

  actions: {
    nope() { alert('This is a no-op in pending-invitation/component.js'); },
    sendInvitation(invitation) {
      invitation.send().then(() => {
        this.get('closeAction')();
      });
    }
  }
});
