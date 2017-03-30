import Ember from 'ember';
import TaskComponent from 'tahi/pods/components/task-base/component';
import FileUploadMixin from 'tahi/mixins/file-upload';
import fontAwesomeFiletypeClass from 'tahi/lib/font-awesome-fyletype-class';
import { uploadManuscriptPath } from 'tahi/utils/api-path-helpers';

const taskValidations = {
  'hasSourceIfNeeded': [{
    type: 'equality',
    message: 'Please upload your source file',
    validation() {
      if (this.get('task.paper.fileType') !== 'pdf') return true;

      let versions = this.get('task.paper.versionedTexts');
      let inRevision = this.get('task.paper.publishingState') === 'in_revision';
      if (inRevision || versions.any(v => v.get('majorVersion') > 0)) {
        return this.get('task.paper.sourcefile');
      } else {
        return true;
      }
    }
  }]
};

export default TaskComponent.extend(FileUploadMixin, {
  progress: 0,
  showProgress: true,
  validations: taskValidations,

  validateData() {
    this.validateAll();
    const taskErrors = this.validationErrorsPresent();

    if(taskErrors) {
      this.set('validationErrors.completed', 'Please correct the errors below');
    }
  },

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

  clearErrors: function() {
    this.set('validationErrors.completed', '');
    this.set('validationErrors.hasSourceIfNeeded', '');
  },

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
