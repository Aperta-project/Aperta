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

  editAllowed: permissionExists('card', 'role', 'edit'),
  viewAllowed: permissionExists('card', 'role', 'view'),

  togglePermission(permissionAction) {
    if (this.get(`${permissionAction}Allowed`)) {
      this.get('turnOffPermission')(this.get('role'), this.get('card'), permissionAction);
    } else {
      this.get('turnOnPermission')(this.get('role'), this.get('card'), permissionAction);
    }
  },

  actions: {
    toggleEditPermission() { this.togglePermission('edit'); },
    toggleViewPermission() { this.togglePermission('view'); }
  }
});
