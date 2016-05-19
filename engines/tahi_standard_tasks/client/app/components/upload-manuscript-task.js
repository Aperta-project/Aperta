import TaskComponent from 'tahi/pods/components/task-base/component';
import FileUploadMixin from 'tahi/mixins/file-upload';
import { uploadManuscriptPath } from 'tahi/lib/api-path-helpers';
import Ember from 'ember';

export default TaskComponent.extend(FileUploadMixin, {
  progress: 0,
  showProgress: true,

  progressBarStyle: Ember.computed('progress', function() {
    return Ember.String.htmlSafe('width:' + this.get('progress') + '%');
  }),

  manuscriptUploadUrl: Ember.computed('task.id', function() {
    return uploadManuscriptPath(this.get('task.id'));
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
      this.store.pushPayload(data);

      this.get('task').save();
    }
  }
});
