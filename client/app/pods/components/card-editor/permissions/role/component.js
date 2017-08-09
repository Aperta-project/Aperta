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

  editAllowed: permissionExists('card', 'role', 'edit'),
  viewAllowed: permissionExists('card', 'role', 'view'),
  edit_discussion_footerAllowed: permissionExists('card', 'role', 'edit_discussion_footer'),
  view_discussion_footerAllowed: permissionExists('card', 'role', 'view_discussion_footer'),

  togglePermission(permissionAction) {
    if (this.get(`${permissionAction}Allowed`)) {
      this.get('turnOffPermission')(this.get('role'), this.get('card'), permissionAction);
    } else {
      this.get('turnOnPermission')(this.get('role'), this.get('card'), permissionAction);
    }
  },

  actions: {
    toggleViewPermission() { this.togglePermission('view'); },
    toggleEditPermission() { this.togglePermission('edit'); },
    toggleViewDiscussionPermission() { this.togglePermission('view_discussion_footer'); },
    toggleEditDiscussionPermission() { this.togglePermission('edit_discussion_footer'); }
  }
});
