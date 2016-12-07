import Ember from 'ember';
import { eligibleUsersPath } from 'tahi/lib/api-path-helpers';
import { task as concurrencyTask } from 'ember-concurrency';

const {
  computed,
  isEmpty
} = Ember;

export default Ember.Component.extend({
  store: Ember.inject.service(),
  restless: Ember.inject.service(),

  // external props
  replaceTargetName: '', // used in template replacements
  endpoint: '', // eligible users endpoint
  placeholder: '', // auto suggest placeholder
  groupByDecision: false,

  //internal stuff
  activeInvitation: null,
  activeInvitationState: 'closed', // 'closed', 'show', 'edit'
  composedInvitation: null,
  selectedUser: null,
  autoSuggestSelectedText: null,

  isEditingInvitation: computed('activeInvitation', 'activeInvitationState', function() {
    return this.get('activeInvitation') && this.get('activeInvitationState') === 'edit';
  }),

  // note that both of these eventually alias to the paper's decisions
  decisions: computed.alias('task.decisions'),
  draftDecision: computed.alias('task.paper.draftDecision'),

  invitations: computed.alias('task.invitations'),

  inviteeRole: computed.reads('task.inviteeRole'),

  loadDecisions: concurrencyTask(function * () {
    return yield this.get('task.decisions');
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

  createInvitation: concurrencyTask(function * (props) {
    let invitation = this.get('store').createRecord('invitation', props);

    this.set('pendingInvitation', invitation);
    try {
      yield invitation.save();

      this.setProperties({
        selectedUser: null,
        pendingInvitation: null,
        autoSuggestSelectedText: null
      });
    } catch(error) {
      // In order to properly throw an ajax error (which allows ember-data
      // to do its thing) we have to wrap the ajax request in a try-catch block
    }
  }),

  persistedInvitations: computed('invitations.@each.isNew', function() {
    const invitations = this.get('invitations');
    return invitations.rejectBy('isNew');
  }),

  draftDecisionInvitations: computed(
    'draftDecision.invitations.@each.inviteeRole', function() {
      const type = this.get('inviteeRole');
      if (this.get('draftDecision.invitations')) {
        return this.get('draftDecision.invitations')
                    .filterBy('inviteeRole', type);
      }
    }
  ),

  previousDecisions: computed.alias('task.paper.previousDecisions'),

  previousDecisionsWithFilteredInvitations: computed(
    'previousDecisions.@each.inviteeRole', function() {
      return this.get('previousDecisions').map(decision => {
        const allInvitations = decision.get('invitations');
        const type = this.get('inviteeRole');
        decision.set(
          'filteredInvitations',
          allInvitations.filterBy('inviteeRole', type)
        );
        return decision;
      });
    }
  ),

  decisionSorting: ['id:desc'],

  sortedPreviousDecisionsWithFilteredInvitations: computed.sort(
      'previousDecisionsWithFilteredInvitations', 'decisionSorting'),

  actions: {
    cancelAction() {
      this.set('selectedUser', null);
      this.set('activeInvitation', null);
    },

    changePosition(newPosition, invitation) {
      this.get('changePosition').perform(newPosition, invitation);
    },

    createInvitation() {
      if (isEmpty(this.get('selectedUser'))) { return; }

      this.get('createInvitation').perform({
        task: this.get('task'),
        email: this.get('selectedUser.email'),
        body: this.buildInvitationBody()
      });
    },

    // auto-suggest action
    didSelectUser(selectedUser) {
      this.set('selectedUser', selectedUser);
    },

    saveInvite(invitation) {
      this.set('composedInvitation', null);
      return invitation.save();
    },

    destroyInvite(invitation) {
      invitation.destroyRecord();
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
