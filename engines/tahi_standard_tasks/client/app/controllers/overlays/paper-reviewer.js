import Ember from 'ember';
import TaskController from 'tahi/pods/paper/task/controller';

const { computed } = Ember;

export default TaskController.extend({
  autoSuggestSourceUrl: computed('model.paper.id', function() {
    return "/api/filtered_users/uninvited_users/" + this.get('model.paper.id');
  }),

  selectedReviewer: null,
  composingEmail: false,
  decisions: computed.alias('model.paper.decisions'),

  customEmail: "test@lvh.me",

  latestDecision: computed('decisions', 'decisions.@each.isLatest', function() {
    return this.get('decisions').findBy('isLatest', true);
  }),

  applyTemplateReplacements: function(str) {
    let reviewerName = this.get('selectedReviewer.full_name');
    if (reviewerName) {
      str = str.replace(/\[REVIEWER NAME\]/g, reviewerName);
    }
    return str.replace(/\[YOUR NAME\]/g, this.get('currentUser.fullName'));
  },

  setLetterTemplate: function() {
    let body, salutation, template;
    template = this.get('model.invitationTemplate');
    if (template.salutation && this.get('selectedReviewer.full_name')) {
      salutation = this.applyTemplateReplacements(template.salutation) + "\n\n";
    } else {
      salutation = "";
    }

    if (template.body) {
      body = this.applyTemplateReplacements(template.body);
    } else {
      body = "";
    }
    return this.set('invitationBody', "" + salutation + body);
  },

  parseUserSearchResponse: function(response) {
    return response.filtered_users;
  },

  displayUserSelected: function(user) {
    return user.full_name + " [" + user.email + "]";
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
      return invitation.destroyRecord();
    },

    didSelectReviewer(selectedReviewer) {
      return this.set('selectedReviewer', selectedReviewer);
    },

    inviteReviewer() {
      if (!this.get('selectedReviewer')) {
        return;
      }
      return this.store.createRecord('invitation', {
        task: this.get('model'),
        email: this.get('selectedReviewer.email'),
        body: this.get('invitationBody')
      }).save().then((invitation) => {
        this.get('latestDecision.invitations').addObject(invitation);
        this.set('composingEmail', false);
        return this.set('selectedReviewer', null);
      });
    },

    removeReviewer(selectedReviewer) {
      return this.store.find('user', selectedReviewer.id).then((user) => {
        this.get('reviewers').removeObject(user);
        return this.send('saveModel');
      });
    },

    inputChanged(val) {
      return this.set('selectedReviewer', {
        email: val
      });
    }
  }
});
