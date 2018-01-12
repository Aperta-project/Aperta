import DS from 'ember-data';
import Attachment from 'tahi/pods/attachment/model';

export default Attachment.extend({
  correspondence: DS.belongsTo('correspondence', { async: true }),
  title: DS.attr('string'),
  src: DS.attr('string')
});
