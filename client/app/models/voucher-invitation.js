import DS from 'ember-data';
import Invitation from 'tahi/models/invitation';

export default Invitation.extend({
  journalLogoUrl: DS.attr('string'),
  paperTitle: DS.attr('string'),
  paperAbstract: DS.attr('string'),
  token: DS.attr('string'),
});
