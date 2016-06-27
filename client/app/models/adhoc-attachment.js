import DS from 'ember-data';
import Attachment from 'tahi/models/attachment'

export default Attachment.extend({
  previewSrc: DS.attr('string'),
  detailSrc: DS.attr('string'),
  src: DS.attr('string')
});
