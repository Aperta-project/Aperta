import TaskComponent from 'tahi/pods/components/task-base/component';
import FileUploadMixin from 'tahi/mixins/file-upload';
import { uploadManuscriptPath } from 'tahi/lib/api-path-helpers';
import fontAwesomeFiletypeClass from 'tahi/lib/font-awesome-fyletype-class';
import Ember from 'ember';

export default TaskComponent.extend(FileUploadMixin, {
  progress: 0,
  showProgress: true,

  pdfAllowed: Ember.computed.reads('task.paper.journal.pdfAllowed'),

  progressBarStyle: Ember.computed('progress', function() {
    return Ember.String.htmlSafe('width:' + this.get('progress') + '%');
  }),

  manuscriptUploadUrl: Ember.computed('task.id', function() {
    return uploadManuscriptPath(this.get('task.id'));
  }),

  fileTypeClass: Ember.computed('filename', 'task.paper.file.filename', function(){
    let uploaded = this.get('manuscriptfileUploaded');
    return fontAwesomeFiletypeClass(this.get(uploaded ? 'filename' : 'task.paper.file.filename'));
  }),

  manuscriptDownloadUrl: Ember.computed('task.paper.id', function() {
    let id = this.get('task.paper.id');
    return '/api/papers/' + id + '/status/' + id + '?job_id=raw&export_format=manuscript';
  }),

  actions: {
    uploadStarted() {
      this.set('showProgress', true);
      this.set('progress', 0);
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

    uploadFinished(data, filename, s3Url) {
      this.uploadFinished(data, filename);
      this.get('store').pushPayload(data);

      this.get('task').save();
      this.set('manuscriptUploaded', true);
      this.set('s3Url', s3Url);
      this.set('filename', filename);
    }
  }
});
