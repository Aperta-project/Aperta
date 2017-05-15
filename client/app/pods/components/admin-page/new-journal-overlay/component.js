import Ember from 'ember';
import EscapeListenerMixin from 'tahi/mixins/escape-listener';
import { PropTypes } from 'ember-prop-types';
import { task } from 'ember-concurrency';

export default Ember.Component.extend(EscapeListenerMixin, {
  propTypes: {
    success: PropTypes.func, // action, called when journal is created
    close: PropTypes.func // action, called to close the overlay
  },

  store: Ember.inject.service(),
  routing: Ember.inject.service('-routing'),
  classNames: ['admin-new-journal-overlay'],
  saving: Ember.computed.reads('createJournal.isRunning'),
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

  createJournal: task(function * () {
    let newJournalProps = this.getProperties([
      'name',
      'description',
      'doiPublisherPrefix',
      'doiJournalPrefix',
      'lastDoiIssued',
      'logoUrl'
    ]);
    const journal = this.get('store').createRecord('admin-journal', newJournalProps);

    try {
      yield journal.save();
      this.get('success')(journal);
      this.redirectToJournal(journal);
      this.get('close')();
    } catch (response) {
      this.set('errors', journal.get('errors'));
    }
  }),

  actions: {
    close() {
      this.get('close')();
      this.clearErrors();
    },

    complete() {
      this.get('createJournal').perform();
    }
  }
});
