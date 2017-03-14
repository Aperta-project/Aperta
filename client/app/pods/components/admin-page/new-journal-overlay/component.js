import Ember from 'ember';
import EscapeListenerMixin from 'tahi/mixins/escape-listener';
import {PropTypes} from 'ember-prop-types';

export default Ember.Component.extend(EscapeListenerMixin, {
  propTypes: {
    success: PropTypes.func, // action, called when journal is created
    close: PropTypes.func // action, called to close the overlay
  },

  store: Ember.inject.service(),
  routing: Ember.inject.service('-routing'),
  classNames: ['admin-new-journal-overlay'],
  saving: false,
  errors: null,

  name: '',
  description: '',
  doiJournalPrefix: '',
  doiPublisherPrefix: '',
  lastDoiIssued: '',
  logoUrl: '',

  clearErrors() {
    this.set('errors', null);
  },

  redirectToJournal(journal) {
    this.get('routing').transitionTo(
      'admin.cc.journals',
      null,
      { journalID: journal.id });
  },

  actions: {
    close() {
      this.get('close')();
      this.clearErrors();
    },

    complete() {
      this.set('saving', true);
      this.clearErrors();

      const journal = this.get('store').createRecord('admin-journal', {
        name: this.get('name'),
        description: this.get('description'),
        doiPublisherPrefix: this.get('doiPublisherPrefix'),
        doiJournalPrefix: this.get('doiJournalPrefix'),
        lastDoiIssued: this.get('lastDoiIssued'),
        logoUrl: this.get('logoUrl')
      });

      journal.save().then(() =>{
        this.set('saving', false);
        this.get('success')(journal);
        this.redirectToJournal(journal);
        this.get('close')();
      }).catch(() => {
        this.set('saving', false);
        this.set('errors', journal.get('errors'));
      });
    }
  }
});
