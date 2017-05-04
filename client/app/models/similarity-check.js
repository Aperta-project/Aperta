import DS from 'ember-data';
import Ember from 'ember';
import { similarityCheckReportPath } from 'tahi/utils/api-path-helpers';


export default DS.Model.extend({
  versionedText: DS.belongsTo('versioned-text'),
  paper: DS.belongsTo('paper'),
  state: DS.attr('string'),
  errorMessage: DS.attr('string'),
  updatedAt: DS.attr('date'),
  score: DS.attr('string'),

  failed: Ember.computed.equal('state', 'failed'),
  succeeded: Ember.computed.equal('state', 'report_complete'),
  incomplete: Ember.computed('state', function() {
    let state = this.get('state');
    return state !== 'report_complete' && state !== 'failed';
  }),

  reportPath: Ember.computed('id', function() {
    return similarityCheckReportPath(this.get('id'));
  }),

  humanReadableState: Ember.computed('state', function() {
    return {
      needs_upload: 'is pending',
      waiting_for_report: 'is in progress',
      failed: 'has failed',
      report_complete: 'succeeded'
    }[this.get('state')];
  })
});
