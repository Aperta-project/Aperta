import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['report-status'],
  readOnly: false,

  statusMessage: Ember.computed('report.status', function() {
    const status = this.get('report.status');
    var output = '';
    switch(status) {
    case 'not_invited':
      output = 'This candidate has not been invited to ' + this.get('report.revision');
      break;
    }
    return output;
  }),

  statusDate: Ember.computed.reads('report.statusDate'),

  reviewerStatus: Ember.computed('report.status', function() {
    const status = this.get('report.status');
    const statuses = {
      'not_invited': 'Not yet invited',
      'completed': 'Completed',
    };
    return statuses[status];
  }),

});
