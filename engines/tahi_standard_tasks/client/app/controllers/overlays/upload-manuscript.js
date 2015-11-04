import Ember from 'ember';
import TaskController from 'tahi/pods/paper/task/controller';
import FileUploadMixin from 'tahi/mixins/file-upload';

export default TaskController.extend(FileUploadMixin, {
  progress: 0,
  showProgress: true,

  progressBarStyle: Ember.computed('progress', function() {
    return Ember.String.htmlSafe('width:' + this.get('progress') + '%');
  }),

  manuscriptUploadUrl: Ember.computed('model.paper.id', function() {
    return '/api/papers/' + this.get('model.paper.id') + '/upload';
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

    uploadError(message) {
      this.set('uploadError', message);
    },

    uploadFinished(data, filename) {
      this.uploadFinished(data, filename);
      this.store.pushPayload(data);

      this.get('model').save().then(()=> {
        this.send('closeAction');
      });
    }
  }
});
