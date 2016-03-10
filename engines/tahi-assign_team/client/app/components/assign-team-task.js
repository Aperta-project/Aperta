import ValidationErrorsMixin from 'tahi/mixins/validation-errors';
import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';
import getOwner from 'ember-getowner-polyfill';

export default TaskComponent.extend(ValidationErrorsMixin, {
  isAssignable: Ember.computed.bool('selectedUser'),

  assignableRoles: Ember.computed.alias('task.assignableRoles'),

  fetchUsers: Ember.observer('selectedRole', function() {
    const paperId = this.get('task.paper.id');
    const selectedRoleId = this.get('selectedRole.id');

    if(!selectedRoleId){
      return;
    } else {
      const path = `/api/papers/${paperId}/roles/${selectedRoleId}/eligible_users`;
      Ember.$.getJSON(path, (data) => {
        this.set('users', data.users);
      });
    }
  }),

  selectableRoles: Ember.computed('assignableRoles', function() {
    const roles = this.get('assignableRoles') || [];

    return roles.map(function(role) {
      return {
        id: role.get('id'),
        text: role.get('name')
      };
    });
  }),

  selectableUsers: Ember.computed('users', function() {
    const users = this.get('users') || [];

    return users.map(function(user) {
      return {
        id: user.id,
        text: user.full_name
      };
    });
  }),

  actions: {
    destroyAssignment(assignment) {
      assignment.destroyRecord();
    },

    assignRoleToUser() {
      const store = getOwner(this).lookup('store:main');
      const userId = this.get('selectedUser.id');

      store.find('user', userId).then(user => {
        let selectedRoleId = this.get('selectedRole.id');
        let role = this.get('assignableRoles').findBy('id', selectedRoleId);
        const assignment = this.store.createRecord('assignment', {
          user: user,
          paper: this.get('task.paper'),
          role: role
        });

        assignment.save().then(()=> {
          this.get('task.assignments').pushObject(assignment);
          this.set('selectedUser', null);
          this.set('users', []);
          this.set('selectedRole', null);
        }, function(response) {
          this.displayValidationErrorsFromResponse(response);
        });
      });
    },

    didSelectRole(role) {
      this.set('selectedRole', role);
    },

    didSelectUser(user) {
      this.set('selectedUser', user);
    }
  }
});
