import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['report-status'],
  readOnly: false,

  statusMessage: Ember.computed('report.status', function() {
    const status = this.get('report.status');
    const invitation_text = 'Invitation to ' + this.get('report.revision') + ' ';
    var output = '';
    switch(status) {
    case 'invitation_pending':
    case 'not_invited':
      output = 'This candidate has not been invited to ' + this.get('report.revision');
      break;
    case 'invitation_invited':
      output = invitation_text + 'sent on ' + this.get('statusDate');
      break;
    case 'pending':
    case 'invitation_accepted':
      output = invitation_text + 'accepted ' + this.get('statusDate');
      break;
    case 'invitation_declined':
      output = invitation_text + 'declined ' + this.get('statusDate');
      break;
    case 'invitation_rescinded':
      output = invitation_text + 'rescinded ' + this.get('statusDate');
      break;
    }
    return output;
  }),

  statusDate: Ember.computed('report.statusDate', function(){
    const date = this.get('report.statusDate');
    const format = 'MMMM D, YYYY';
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
