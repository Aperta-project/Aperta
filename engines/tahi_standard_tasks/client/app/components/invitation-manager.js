import Ember from 'ember';
import { eligibleUsersPath } from 'tahi/lib/api-path-helpers';
import { task } from 'ember-concurrency';

const {
  computed,
  isEmpty
} = Ember;

export default Ember.Component.extend({
  store: Ember.inject.service(),

  // external props
  replaceTargetName: '', // used in template replacements
  endpoint: '', // eligible users endpoint
  placeholder: '', // auto suggest placeholder
  groupByDecision: false,

  //internal stuff
  activeInvitation: null,
  activeInvitationState: 'closed',
  selectedUser: null,
  autoSuggestSelectedText: null,

  decisions: computed.alias('task.decisions'),

  latestDecision: computed('decisions', 'decisions.@each.latest', function() {
    return this.get('decisions').findBy('latest', true);
  }),


  applyTemplateReplacements(str) {
    const name = this.get('selectedUser.full_name');
    if (name) {
      let regexp = new RegExp('\\[' + this.get('replaceTargetName') + '\\]', 'g');
      str = str.replace(regexp, name);
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

  autoSuggestSourceUrl: computed('task.id', 'endpoint', function(){
    return eligibleUsersPath(this.get('task.id'), this.get('endpoint'));
  }),

  parseUserSearchResponse(response) {
    return response.users;
  },

  displayUserSelected(user) {
    return user.full_name + ' <' + user.email + '>';
  },

  createInvitation: task(function * (props) {
    let invitation = this.get('store').createRecord('invitation', props);
    this.set('pendingInvitation', invitation);
    try {
      yield invitation.save();
      if (this.get('groupByDecision')) {
        this.get('latestDecision.invitations').addObject(invitation);
      }

      this.setProperties({
        activeInvitation: invitation,
        activeInvitationState: 'edit',
        selectedUser: null,
        pendingInvitation: null,
        autoSuggestSelectedText: null
      });
    } catch(error) {
      // In order to properly throw an ajax error (which allows ember-data
      // to do its thing) we have to wrap the ajax request in a try-catch block
    }
  }),

  actions: {
    cancelAction() {
      this.set('selectedUser', null);
      this.set('activeInvitation', null);
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

    toggleActiveInvitation(invitation, rowState) {
      this.set('activeInvitation', invitation);
      this.set('activeInvitationState', rowState);
    },

    // auto-suggest action
    inputChanged(val) {
      this.set('autoSuggestSelectedText', val);
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
