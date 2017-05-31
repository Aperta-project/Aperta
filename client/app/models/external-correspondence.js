import Correspondence from 'tahi/models/correspondence';

export default Correspondence.extend({
  cc: DS.attr('string'),
  bcc: DS.attr('string'),
  description: DS.attr('string')
});
