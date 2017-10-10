import DS from 'ember-data';
import Invitation from 'tahi/models/invitation';

export default Invitation.extend({
  information: DS.attr('string'),
  journalLogoUrl: DS.attr('string'),
  paperTitle: DS.attr('string'),
  paperAbstract: DS.attr('string'),
});
