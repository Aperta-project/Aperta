import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['report-status'],
  readOnly: false,
  shortStatus: Ember.computed.reads('short'),

  statusSubMessage: Ember.computed('report.status','report.revision','statusDate', function() {
    const status = this.get('report.status');
    var output = '';    const verbs = {
      'pending': 'accepted',
      'invitation_invited': 'sent on',
      'invitation_accepted': 'accepted',
      'invitation_declined': 'declined',
      'invitation_rescinded': 'rescinded'
    };
    if (['invitation_pending', 'not_invited'].includes(status)) {
      output = 'This candidate has not been invited to ' + this.get('report.revision');
    } else {
      output = `Invitation ${verbs[status]} ${this.get('statusDate')}`;
    }
    return output;
  }),

  statusMessage: Ember.computed('report.status','report.revision','reviewDueAt', function() {
    const status = this.get('report.status');
    var output = '';

    if (['invitation_pending', 'not_invited'].includes(status)) {
      output = '';
    } else {
      output = 'review of ' + this.get('report.revision') + ' due ' + this.get('reviewDueAt');
    }
    return output;
  }),

  statusDate: Ember.computed('report.statusDatetime', function(){
    const date = this.get('report.statusDatetime');
    const format = 'MMMM D, YYYY';
    return moment(date).format(format);
  }),

  reviewDueAt: Ember.computed('report.dueAt', function(){
    const date = this.get('report.dueAt');
    const format = 'MMMM D, YYYY  hh:mm a';
    return moment(date).format(format);
  }),

  reviewerStatus: Ember.computed('report.status', function() {
    const status = this.get('report.status');
    const statuses = {
      'pending': 'Pending',
      'not_invited': 'Not yet invited',
      'completed': 'Completed',
      'invitation_pending': 'Not yet invited',
      'invitation_invited': 'Invited',
      'invitation_accepted': 'Pending',
      'invitation_declined': 'Declined',
      'invitation_rescinded': 'Rescinded'
    };
    return statuses[status];
  }),

});
