import Invitation from 'tahi/models/invitation';
import DS from 'ember-data';

export default Invitation.extend({
  journalStaffEmail: DS.attr('string')
});
