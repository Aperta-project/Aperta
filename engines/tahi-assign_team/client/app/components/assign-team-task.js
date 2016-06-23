import ValidationErrorsMixin from 'tahi/mixins/validation-errors';
import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';

export default TaskComponent.extend(ValidationErrorsMixin, {
  isAssignable: Ember.computed.bool('selectedUser'),
  store: Ember.inject.service(),

  assignableRoles: Ember.computed.alias('task.assignableRoles'),
  selectableRoles: Ember.computed('assignableRoles', function() {
    const roles = this.get('assignableRoles') || [];
    return roles.map(function(role) {
      return {
        id: role.get('id'),
        text: role.get('name')
      };
    });
  }),

  select2RemoteSource: Ember.computed('select2RemoteUrl', function(){
    const url = this.get('select2RemoteUrl');
    if(!url) return;

    return {
      url: url,
      dataType: 'json',
      quietMillis: 500,
      data: function(term) {
        return { query: term };
      },
      results: function(data) {
        const selectableUsers = data.users.map(function(user){
          return {
            id: user.id,
            text: user.full_name
          };
        });
        return { results: selectableUsers };
      }
    };
  }),

  actions: {
    destroyAssignment(assignment) {
      assignment.destroyRecord();
    },

    assignRoleToUser() {
      const store = this.get('store');

      let user = store.findOrPush('user', this.get('selectedUser'));

      let selectedRoleId = this.get('selectedRole.id');
      let role = this.get('assignableRoles').findBy('id', selectedRoleId);
      const assignment = store.createRecord('assignment', {
        user: user,
        paper: this.get('task.paper'),
        role: role
      });

      assignment.save().then(()=> {
        this.get('task.assignments').pushObject(assignment);
        this.set('selectedUser', null);
        this.set('selectedRole', null);

        // Make sure we don't allow the previous list of users searchable or
        // selectable. Force a role must be selected first.
        this.set('select2RemoteUrl', null);
      }, function(response) {
        this.displayValidationErrorsFromResponse(response);
      });
    },

    didSelectRole(role) {
      const paperId = this.get('task.paper.id');
      const roleId = role.id;

      Ember.assert(`Expected to have a paper.id but didn't`, paperId);
      Ember.assert(`Expected to have a role.id but didn't`, roleId);

      this.set('selectedUser', null);

      let url = `/api/papers/${paperId}/roles/${roleId}/eligible_users`;
      this.set('selectedRole', role);
      this.set('select2RemoteUrl', url);
    },

    didSelectUser(user) {
      this.set('selectedUser', user);
    }
  }
});
