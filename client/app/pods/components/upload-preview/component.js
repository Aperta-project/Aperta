import Ember from 'ember';

export default Ember.Component.extend({
  classNameBindings: [':_uploading', 'error:alert'],

  file: Ember.computed.alias('upload.file'),
  filename: Ember.computed.alias('file.name'),
  error: null,

  /**
   * @property upload
   * @type {FileUpload} Ember.Object
   * @default null
   * @required
   */
  upload: null,

  previewText: Ember.computed('filename', 'upload.uploadFinished', function(){
    let filename = this.get('filename');
    if (this.get('upload.uploadFinished') === true) {
      return 'Upload Complete! ' + filename;
    }
    return 'Loading ' + filename + '...';
  }),
  preview: Ember.computed('file.preview', function() {
    let preview = this.get('file.preview');
    return preview !== null ? preview.toDataURL() : void 0;
  }),

  progress: Ember.computed('upload.dataLoaded', 'upload.dataTotal', function() {
    return Math.round(this.get('upload.dataLoaded') * 100 / this.get('upload.dataTotal'));
  }),

  progressBarStyle: Ember.computed('progress', function() {
    return Ember.String.htmlSafe('width: ' + (this.get('progress')) + '%;');
  }),

  _removeProgressBar: Ember.observer('upload.uploadFinished', function() {
    this.$().delay(1000).slideUp(300);
  }),

});
