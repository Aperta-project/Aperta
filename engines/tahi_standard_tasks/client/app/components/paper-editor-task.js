import Ember from 'ember';
import TaskComponent from 'tahi/pods/components/task-base/component';
import { eligibleUsersPath } from 'tahi/lib/api-path-helpers';

const {
  computed,
  inject,
  isEmpty
} = Ember;

export default TaskComponent.extend({
  restless: inject.service(),

  invitationToEdit: null,
  selectedUser: null,
  composingEmail: false,

  applyTemplateReplacements(str) {
    const name = this.get('selectedUser.full_name');
    if (name) {
      str = str.replace(/\[EDITOR NAME\]/g, name);
    }
    return str.replace(/\[YOUR NAME\]/g, this.get('currentUser.fullName'));
  },

  setLetterTemplate: function() {
    let body, salutation, template;
    template = this.get('task.invitationTemplate');
    if (template.salutation && this.get('selectedUser.full_name')) {
      salutation = this.applyTemplateReplacements(template.salutation) + '\n\n';
    } else {
      salutation = '';
    }

    if (template.body) {
      body = this.applyTemplateReplacements(template.body);
    } else {
      body = '';
    }
    return this.set('invitationBody', '' + salutation + body);
  },

  // auto-suggest
  autoSuggestSourceUrl: computed('task.id', function(){
    return eligibleUsersPath(this.get('task.id'), 'academic_editors');
  }),

  // auto-suggest
  parseUserSearchResponse(response) {
    return response.users;
  },

  // auto-suggest
  displayUserSelected(user) {
    return user.full_name + ' [' + user.email + ']';
  },

  actions: {
    cancelAction() {
      this.set('selectedUser', null);
      this.set('invitationToEdit', null);
    },

    composeInvite() {
      if (isEmpty(this.get('selectedUser'))) { return; }

      this.setLetterTemplate();

      this.get('store').createRecord('invitation', {
        task: this.get('task'),
        email: this.get('selectedUser.email'),
        body: this.get('invitationBody'),
        state: 'pending'
      }).save().then((invitation) => {
        this.setProperties({
          invitationToEdit: invitation,
          selectedUser: null
        });
      });
    },

    // auto-suggest action
    didSelectUser(selectedUser) {
      this.set('selectedUser', selectedUser);
    },

    // auto-suggest action
    inputChanged(val) {
      if(isEmpty(val)) {
        this.set('selectedUser', null);
        return;
      }

      this.set('selectedUser', {
        email: val
      });
    }
  }
});
