import Invitation from 'tahi/pods/invitation/model';
import DS from 'ember-data';

export default Invitation.extend({
  journalStaffEmail: DS.attr('string')
});
