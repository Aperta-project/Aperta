import DS from 'ember-data';
import Ember from 'ember';
import Attachment from 'tahi/models/attachment';
import { paperDownloadPath } from 'tahi/utils/api-path-helpers';
export default Attachment.extend({
  previewSrc: DS.attr('string'),
  detailSrc: DS.attr('string'),
  fileHash: DS.attr('string'),
  task: null, //only used ephemerally
  fileDownloadUrl: Ember.computed('paper', function() {
    return paperDownloadPath({ paperId: this.get('paper.id') });
  }),
  s3Url: DS.attr('string'), // set by file uploader

  src: Ember.computed.or('s3Url', 'fileDownloadUrl'),

  computedFileType: Ember.computed('src', 'fileType', function() {
    return this.get('fileType') || this.get('src').split('.').get('lastObject');
  }),
  cancelUploadPath() {
    return `/api/manuscript_attachments/${this.get('id')}/cancel`;
  }
});
