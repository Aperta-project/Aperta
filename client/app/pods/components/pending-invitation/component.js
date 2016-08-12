import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  propTypes: {
    user: PropTypes.object.isRequired,
    invitation: PropTypes.object.isRequired
  },
  classNames: ['invite-editor-edit-invite'],

  actions: {
    nope() { console.log('This is a no-op in pending-invitation/component.js'); },
    sendInvitation() { console.log('Send it on');},
    cancelAction() { console.log('Delete pending invitation');}
  }
});
