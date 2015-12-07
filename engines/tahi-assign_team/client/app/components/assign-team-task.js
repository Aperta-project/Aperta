import ValidationErrorsMixin from 'tahi/mixins/validation-errors';
import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';

export default TaskComponent.extend(ValidationErrorsMixin, {
  init() {
    this._super(...arguments);

    const path = '/api/papers/' + (this.get('task.paper.id')) + '/roles';
    Ember.$.getJSON(path, (data) => {
      this.set('roles', data.roles);
    });
  },

  isAssignable: false,

  fetchUsers: function() {
    const paperId = this.get('task.paper.id');
    const roleId  = this.get('selectedRole.id');
    const path    = '/api/papers/' + paperId + '/roles/' + roleId + '/users';

    Ember.$.getJSON(path, (data) => {
      this.set('users', data.users);
    });
  }.observes('selectedRole'),

  selectableRoles: Ember.computed('roles', function() {
    const roles = this.get('roles') || [];

    return roles.map(function(role) {
      return {
        id: role.id,
        text: role.name
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
      const store = this.container.lookup('store:main');
      const userId = this.get('selectedUser.id');

      store.find('user', userId).then(user => {
        const assignment = this.store.createRecord('assignment', {
          user: user,
          paper: this.get('task.paper'),
          role: this.get('selectedRole.text')
        });

        assignment.save().then(()=> {
          this.get('task.assignments').pushObject(assignment);
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
      this.set('isAssignable', true);
    }
  }
});
