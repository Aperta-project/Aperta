import Invitation from 'tahi/models/invitation';

export default Invitation.extend({
  token: DS.attr('string'),
  journalStaffEmail: DS.attr('string')
});
