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

  preview: function() {
    let preview = this.get('file.preview');
    return preview != null ? preview.toDataURL() : void 0;
  }.property('file.preview'),

  progress: function() {
    return Math.round(this.get('upload.dataLoaded') * 100 / this.get('upload.dataTotal'));
  }.property('upload.dataLoaded', 'upload.dataTotal'),

  progressBarStyle: function() {
    return Ember.String.htmlSafe('width: ' + (this.get('progress')) + '%;');
  }.property('progress')
});
