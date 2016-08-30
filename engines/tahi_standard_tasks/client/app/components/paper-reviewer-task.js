import Ember from 'ember';
import TaskComponent from 'tahi/pods/components/task-base/component';
import { eligibleUsersPath } from 'tahi/lib/api-path-helpers';
import { task } from 'ember-concurrency';

const {
  computed,
  computed: {alias},
  isEmpty
} = Ember;

//Note: This is component is strikingly similar to the paper-editor-task component,
//but we didn't feel that combining the two was worth the time as part of APERTA-5588.
//Please take a look a the `paper-editor-task` as you make changes here.
export default TaskComponent.extend({
  invitationToEdit: null,
  selectedUser: null,
  decisions: alias('task.decisions'),

  latestDecision: computed('decisions', 'decisions.@each.latest', function() {
    return this.get('decisions').findBy('latest', true);
  }),

  applyTemplateReplacements(str) {
    const name = this.get('selectedUser.full_name');
    if (name) {
      str = str.replace(/\[REVIEWER NAME\]/g, name);
    }
    return str.replace(/\[YOUR NAME\]/g, this.get('currentUser.fullName'));
  },

  buildInvitationBody() {
    const template = this.get('task.invitationTemplate');
    let body, salutation = '';

    if (template.salutation && this.get('selectedUser.full_name')) {
      salutation = this.applyTemplateReplacements(template.salutation) + '\n\n';
    }

    if (template.body) {
      body = this.applyTemplateReplacements(template.body);
    }

    return '' + salutation + body;
  },

  // auto-suggest
  autoSuggestSourceUrl: computed('task.id', function() {
    return eligibleUsersPath(this.get('task.id'), 'reviewers');
  }),

  // auto-suggest
  parseUserSearchResponse(response) {
    return response.users;
  },

  // auto-suggest
  displayUserSelected(user) {
    return user.full_name + ' <' + user.email + '>';
  },

  createInvitation: task(function * (props) {
    let invitation = this.get('store').createRecord('invitation', props);
    this.set('pendingInvitation', invitation);
    try {
      yield invitation.save();
      this.get('latestDecision.invitations').addObject(invitation);

      this.setProperties({
        invitationToEdit: invitation,
        selectedUser: null,
        pendingInvitation: null
      });
    } catch(error) {
      // In order to properly throw an ajax error (which allows ember-data
      // to do its thing) we have to wrap the ajax request in a try-catch block
    }
  }),

  actions: {
    cancelAction() {
      this.set('selectedUser', null);
      this.set('invitationToEdit', null);
    },

    composeInvite() {
      if (isEmpty(this.get('selectedUser'))) { return; }

      this.get('createInvitation').perform({
        task: this.get('task'),
        email: this.get('selectedUser.email'),
        body: this.buildInvitationBody(),
        state: 'pending'
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
