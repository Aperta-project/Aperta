import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';
import { task, timeout } from 'ember-concurrency';

const {
  Component,
  computed,
  computed: { alias, equal, not }
} = Ember;

/*
 * UI States: closed, show, edit
 */

export default Component.extend({
  classNameBindings: [':invitation-item', 'invitationStateClass', 'uiStateClass'],

  propTypes: {
    invitation: PropTypes.EmberObject.isRequired,
    destroyAction: PropTypes.func.isRequired
  },

  uiStateClass: computed('uiState', function() {
    return 'invitation-item--' + this.get('uiState');
  }),

  invitationStateClass: computed('invitation.state', function() {
    return 'invitation-state--' + this.get('invitation.state');
  }),

  invitee: alias('invitation.invitee'),

  displayDestroyButton: computed('invitation.accepted', 'closedState', function() {
    return !this.get('invitation.accepted') && this.get('notClosedState');
  }),

  uiState: 'closed',
  closedState: equal('uiState', 'closed'),
  notClosedState: not('closedState'),
  editState: equal('uiState', 'edit'),

  fetchDetails: task(function * (invitation) {
    const promise = invitation.fetchDetails();
    yield promise;
    return promise;
  }),

  templateSaved: task(function * () {
    yield timeout(2000);
  }).keepLatest(),

  actions: {
    editInvitation() {
      this.set('uiState', 'edit');
    },

    toggleDetails(invitation) {
      if (this.get('closedState')) {
        this.get('fetchDetails').perform(invitation).then(()=> {
          this.set('uiState', 'show');
        });

        return;
      }

      this.set('uiState', 'closed');
    },

    cancelEdit(invitation) {
      invitation.rollbackAttributes();
      this.set('uiState', 'show');
    },

    saveDuringType() {
      // TODO: save
      this.get('templateSaved').perform();
    },

    save(invitation) {
      invitation.save().then(() => {
        this.set('uiState', 'show');
      });
    }
  }
});
