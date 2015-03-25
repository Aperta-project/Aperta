import Ember from 'ember';
import TaskController from 'tahi/pods/task/controller';
import FileUploadMixin from 'tahi/mixins/file-upload';

export default TaskController.extend(FileUploadMixin, {
  progress: 0,
  isProcessing: false,
  showProgress: true,

  isEditable: function() {
    return !this.get('paper.lockedBy') && (this.get('isUserEditable') || this.get('isCurrentUserAdmin'));
  }.property('paper.lockedBy', 'isUserEditable', 'isCurrentUserAdmin'),

  progressBarStyle: function() {
    return this.get('progress') + '%';
  }.property('progress'),

  manuscriptUploadUrl: function() {
    return '/papers/' + this.get('litePaper.id') + '/upload';
  }.property('litePaper.id'),

  actions: {
    uploadProgress: function(data) {
      var self = this;
      this.set('progress', Math.round((data.loaded / data.total) * 100));

      if(this.get('progress') >= 100) {
        setTimeout(function() {
          self.setProperties({showProgress: false, isProcessing: true});
        }, 500);
      }
    },

    uploadError: function(message) {
      this.set('uploadError', message);
    },

    uploadFinished: function(data, filename) {
      var self = this;
      this.uploadFinished(data, filename);
      this.store.pushPayload(data);
      this.set('completed', true);

      this.get('model').save().then(function() {
        self.send('closeAction');
      });
    }
  }
});
