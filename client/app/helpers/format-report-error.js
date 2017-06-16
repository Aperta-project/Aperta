import Ember from 'ember';

export function formatReportError(params/*, hash*/) {
  let message = params[0];
  message.set('text', `<strong>Report not available:</strong> ${message.get('text')} <br>Click below to try again. If you continue to experience problems generating a report, please contact support.`);
  return message;
}

export default Ember.Helper.helper(formatReportError);
