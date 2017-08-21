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
    toggleViewDiscussionFooterPermission() { this.togglePermission('view_discussion_footer'); },
    toggleEditDiscussionFooterPermission() { this.togglePermission('edit_discussion_footer'); }
  }
});
