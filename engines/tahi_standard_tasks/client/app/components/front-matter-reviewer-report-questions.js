import Ember from 'ember';
import { task as concurrencyTask } from 'ember-concurrency';

export default Ember.Component.extend({
  readOnly: false,
  hasReport: Ember.computed('model.status', function() {
    const reportStatus = this.get('model.status');
    const hasReportStates = ['pending', 'completed', 'invitation_accepted'];
    return hasReportStates.includes(reportStatus);
  }),
  loadCard: concurrencyTask( function * () {
    let model = this.get('model');
    yield Ember.RSVP.all([
      model.get('card'),
      model.get('answers')
    ]);
  }),
  competingInterestsLink: Ember.computed('model.task.paper.journal.name', function() {
    const name = this.get('model.task.paper.journal.name');
    if (name) {
      return `http://journals.plos.org/${name.toLowerCase().replace(' ', '')}/s/reviewer-guidelines#loc-competing-interests`;
    } else {
      return 'http://journals.plos.org/';
    }
  }),
});
