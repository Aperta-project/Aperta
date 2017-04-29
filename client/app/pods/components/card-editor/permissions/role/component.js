import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  propTypes: {
    card: PropTypes.EmberObject.isRequired,
    role: PropTypes.EmberObject.isRequired,
    turnOnPermission: PropTypes.func.isRequired,
    turnOffPermission: PropTypes.func.isRequired
  },

  editPermission: Ember.computed('card', 'role.cardPermissions.[]', function () {
    return this.getPermissionFor('edit');
  }),

  viewPermission: Ember.computed('card', 'role.cardPermissions.[]', function () {
    return this.getPermissionFor('view');
  }),

  editAllowed: Ember.computed.notEmpty('editPermission'),
  viewAllowed: Ember.computed.notEmpty('viewPermission'),

  getPermissionFor(permissionAction) {
    return this.get('role.cardPermissions').find((perm)=>{
      return perm.get('permissionAction') === permissionAction &&
        perm.get('filterByCardId') === this.get('card.id');
    });
  },

  togglePermission(permissionAction) {
    if (this.get(`${permissionAction}Allowed`)) {
      this.get('turnOffPermission')(this.get('role'), this.get('card'), permissionAction);
    } else {
      this.get('turnOnPermission')(this.get('role'), this.get('card'), permissionAction);
    }
  },

  actions: {
    toggleEditPermission() {
      this.togglePermission('edit');
    },
    toggleViewPermission() {
      this.togglePermission('view');
    }
  }
});
