import Ember from 'ember';

export default Ember.Component.extend({
  readOnly: false,

  versionString: Ember.computed('report.decision.{draft,revisionNumber}', 'report.task.paper.currentVersionString', function() {
    var version = 'v';
    if (this.get('report.decision.draft')){
      version += this.get('report.task.paper.currentVersionString');
    }else{
      version += this.get('report.decision.revisionNumber');
    }
    return version;
  }),

  statusMessage: Ember.computed('report.status', 'versionString', function() {
    const status = this.get('report.status');
    var output = '';
    switch(status) {
    case 'not_invited':
      output = 'This candidate has not been invited to ' + this.get('versionString');
      break;
    }
    return output;
  }),

  statusDate: Ember.computed('report.status', function() {

  }),

  reviewerStatus: Ember.computed('report.status', function() {
    const status = this.get('report.status');
    const statuses = {
      'not_invited': 'Not yet invited',
      'completed': 'Completed',
    };
    return statuses[status];
  }),

});
