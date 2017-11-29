import Ember from 'ember';

export default Ember.Component.extend({
  readOnly: false,
  hasReport: Ember.computed('report.status', function() {
    const reportStatus = this.get('report.status');
    const hasReportStates = ['pending', 'completed', 'invitation_accepted'];
    return hasReportStates.includes(reportStatus);
  }),

  competingInterestsLink: Ember.computed('report.task.paper.journal.name', function() {
    const name = this.get('report.task.paper.journal.name');
    if (name) {
      return `http://journals.plos.org/${name.toLowerCase().replace(' ', '')}/s/reviewer-guidelines#loc-competing-interests`;
    } else {
      return 'http://journals.plos.org/';
    }
  }),
});
