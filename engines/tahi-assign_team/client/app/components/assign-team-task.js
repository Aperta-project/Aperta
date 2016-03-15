import ValidationErrorsMixin from 'tahi/mixins/validation-errors';
import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';
import getOwner from 'ember-getowner-polyfill';

export default TaskComponent.extend(ValidationErrorsMixin, {
  init() {
    this._super(...arguments);

    const path = '/api/papers/' + (this.get('task.paper.id')) + '/old_roles';
    Ember.$.getJSON(path, (data) => {
      this.set('oldRoles', data.old_roles);
    });
  },

  isAssignable: false,

  fetchUsers: function() {
    const paperId = this.get('task.paper.id');
    const oldRoleId  = this.get('selectedOldRole.id');
    const path    = '/api/papers/' + paperId + '/old_roles/' + oldRoleId + '/users';

    Ember.$.getJSON(path, (data) => {
      this.set('users', data.users);
    });
  }.observes('selectedOldRole'),

  selectableRoles: Ember.computed('oldRoles', function() {
    const oldRoles = this.get('oldRoles') || [];

    return oldRoles.map(function(oldRole) {
      return {
        id: oldRole.id,
        text: oldRole.name
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

    assignOldRoleToUser() {
      const store = getOwner(this).lookup('store:main');
      const userId = this.get('selectedUser.id');

      store.find('user', userId).then(user => {
        const assignment = this.store.createRecord('assignment', {
          user: user,
          paper: this.get('task.paper'),
          oldRole: this.get('selectedOldRole.text')
        });

        assignment.save().then(()=> {
          this.get('task.assignments').pushObject(assignment);
        }, function(response) {
          this.displayValidationErrorsFromResponse(response);
        });
      });
    },

    didSelectRole(oldRole) {
      this.set('selectedOldRole', oldRole);
    },

    didSelectUser(user) {
      this.set('selectedUser', user);
      this.set('isAssignable', true);
    }
  }
});
