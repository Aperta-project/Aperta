import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';
import { permissionExists } from 'tahi/lib/admin-card-permission';

export default Ember.Component.extend({
  propTypes: {
    card: PropTypes.EmberObject.isRequired,
    role: PropTypes.EmberObject.isRequired,
    turnOnPermission: PropTypes.func.isRequired,
    turnOffPermission: PropTypes.func.isRequired
  },

  tagName: 'tr',

  viewAllowed: permissionExists('card', 'role', 'view'),
  editAllowed: permissionExists('card', 'role', 'edit'),
  view_discussion_footerAllowed: permissionExists('card', 'role', 'view_discussion_footer'),
  edit_discussion_footerAllowed: permissionExists('card', 'role', 'edit_discussion_footer'),
  be_assignedAllowed: permissionExists('card', 'role', 'be_assigned'),
  assign_othersAllowed: permissionExists('card', 'role', 'assign_others'),
  view_participantsAllowed: permissionExists('card', 'role', 'view_participants'),
  manage_participantAllowed: permissionExists('card', 'role', 'manage_participant'),
  actions: {
    togglePermission(permissionAction) {
      if (this.get(`${permissionAction}Allowed`)) {
        this.get('turnOffPermission')(this.get('role'), this.get('card'), permissionAction);
      } else {
        this.get('turnOnPermission')(this.get('role'), this.get('card'), permissionAction);
      }
    }
  }
});
