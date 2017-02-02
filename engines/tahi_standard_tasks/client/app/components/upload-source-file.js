import FileUploadMixin from 'tahi/mixins/file-upload';
import { uploadSourceFilePath } from 'tahi/lib/api-path-helpers';
import Ember from 'ember';

export default Ember.Component.extend(FileUploadMixin, {
  progress: 0,
  showProgress: true,

  pdfAllowed: false,

  progressBarStyle: Ember.computed('progress', function() {
    return Ember.String.htmlSafe('width:' + this.get('progress') + '%');
  }),

  sourceFileUploadUrl: Ember.computed('task.id', function() {
    return uploadSourceFilePath(this.get('task.id'));
  }),

  actions: {
    uploadStarted() {
      this.uploadStarted(...arguments);
    },

    uploadProgress(data) {
      const progress = Math.round((data.loaded / data.total) * 100);
      this.set('progress', progress);

      if(progress < 100) { return; }

      Ember.run.later(this, function() {
        this.set('showProgress', false);
      }, 500);
    },

    fileAddError(message, {fileName}) {
      this.setProperties({fileName: fileName, uploadError: true});
    },

    uploadError(message) {
      this.set('uploadError', message);
    },

    uploadFinished(data, filename) {
      this.uploadFinished(data, filename);
      this.get('store').pushPayload(data);

      this.get('task').save();
    }
  }
});
