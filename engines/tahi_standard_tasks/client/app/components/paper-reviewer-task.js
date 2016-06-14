import Ember from 'ember';
import TaskComponent from 'tahi/pods/components/task-base/component';
import { eligibleUsersPath } from 'tahi/lib/api-path-helpers';

const { computed } = Ember;

export default TaskComponent.extend({
  autoSuggestSourceUrl: computed('task.id', function() {
    return eligibleUsersPath(this.get('task.id'), 'reviewers');
  }),

  selectedReviewer: null,
  composingEmail: false,
  decisions: computed.alias('task.decisions'),

  customEmail: 'test@lvh.me',

  latestDecision: computed('decisions', 'decisions.@each.isLatest', function() {
    return this.get('decisions').findBy('isLatest', true);
  }),

  applyTemplateReplacements(str) {
    let reviewerName = this.get('selectedReviewer.full_name');
    if (reviewerName) {
      str = str.replace(/\[REVIEWER NAME\]/g, reviewerName);
    }
    return str.replace(/\[YOUR NAME\]/g, this.get('currentUser.fullName'));
  },

  setLetterTemplate() {
    let body, salutation, template;
    template = this.get('task.invitationTemplate');
    if (template.salutation && this.get('selectedReviewer.full_name')) {
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

  parseUserSearchResponse(response) {
    return response.users;
  },

  displayUserSelected(user) {
    return user.full_name + ' <' + user.email + '>';
  },

  actions: {
    cancelAction() {
      this.set('selectedReviewer', null);
      return this.set('composingEmail', false);
    },

    composeInvite() {
      if (!this.get('selectedReviewer')) {
        return;
      }
      this.setLetterTemplate();
      return this.set('composingEmail', true);
    },

    destroyInvitation(invitation) {
      return invitation.rescind();
    },

    didSelectReviewer(selectedReviewer) {
      return this.set('selectedReviewer', selectedReviewer);
    },

    inviteReviewer() {
      if (!this.get('selectedReviewer')) {
        return;
      }
      return this.store.createRecord('invitation', {
        task: this.get('task'),
        email: this.get('selectedReviewer.email'),
        body: this.get('invitationBody')
      }).save().then((invitation) => {
        this.get('latestDecision.invitations').addObject(invitation);
        this.set('composingEmail', false);
        return this.set('selectedReviewer', null);
      });
    },

    inputChanged(val) {
      return this.set('selectedReviewer', {
        email: val
      });
    }
  }
});
