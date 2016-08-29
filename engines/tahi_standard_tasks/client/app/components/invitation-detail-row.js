import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';
import { task, timeout } from 'ember-concurrency';

const {
  Component,
  computed,
  computed: { equal, not, and, reads },
  inject: { service }
} = Ember;

/*
 * UI States: closed, show, edit
 *
 * EventBus is for closing all rows when one is opened
 */

export default Component.extend({
  eventBus: service('event-bus'),
  classNameBindings: [':invitation-item', 'invitationStateClass', 'uiStateClass'],

  propTypes: {
    invitation: PropTypes.EmberObject.isRequired,
    destroyAction: PropTypes.func.isRequired
  },

  allowAttachments: true,
  uiStateClass: computed('uiState', function() {
    return 'invitation-item--' + this.get('uiState');
  }),

  invitationStateClass: computed('invitation.state', function() {
    return 'invitation-state--' + this.get('invitation.state');
  }),

  invitee: reads('invitation.invitee'),
  invitationBodyStateBeforeEdit: null,

  displayEditButton: and('invitation.pending', 'notClosedState'),
  displaySendButton: reads('invitation.pending'),
  displayDestroyButton: computed('invitation.accepted', 'closedState', function() {
    return !this.get('invitation.accepted') && this.get('notClosedState');
  }),

  uiState: 'closed',

  closedState: equal('uiState', 'closed'),
  notClosedState: not('closedState'),
  editState: equal('uiState', 'edit'),

  didInsertElement() {
    this._super(...arguments);

    this.get('eventBus').subscribe('invitation-row-toggle', this, function(id) {
      if(id === this.get('invitation.id')) { return; }
      this.set('uiState', 'closed');
    });
  },

  willDestroyElement() {
    this._super(...arguments);
    this.get('eventBus').unsubscribe('invitation-row-toggle', this);
  },

  fetchDetails: task(function * (invitation) {
    const promise = invitation.fetchDetails();
    yield promise;
    return promise;
  }),

  templateSaved: task(function * () {
    yield timeout(2000);
  }).keepLatest(),

  openRow(invitation) {
    this.get('fetchDetails').perform(invitation).then(()=> {
      this.get('eventBus').publish('invitation-row-toggle', invitation.id);
      this.set('uiState', 'show');
    });
  },

  actions: {
    editInvitation(invitation) {
      this.setProperties({
        invitationBodyStateBeforeEdit: invitation.get('body'),
        uiState: 'edit'
      });
    },

    toggleDetails(invitation) {
      if (this.get('closedState')) {
        this.openRow(invitation);
      } else {
        this.set('uiState', 'closed');
      }
    },

    cancelEdit(invitation) {
      invitation.rollbackAttributes();
      invitation.set('body', this.get('invitationBodyStateBeforeEdit'));
      invitation.save();
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
    },

    sendInvitation(invitation) {
      invitation.send();
    }
  }
});
