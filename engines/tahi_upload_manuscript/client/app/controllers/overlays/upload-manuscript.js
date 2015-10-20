import Ember from 'ember';
import TaskController from 'tahi/pods/paper/task/controller';
import FileUploadMixin from 'tahi/mixins/file-upload';

export default TaskController.extend(FileUploadMixin, {
  progress: 0,
  isProcessing: false,
  showProgress: true,

  canUploadManuscript: function() {
    return (this.get('currentUser') === this.get('model.paper.lockedBy')) || this.get('isEditable');
  }.property('model.paper.lockedBy', 'isEditable'),

  progressBarStyle: function() {
    return Ember.String.htmlSafe('width:' + this.get('progress') + '%');
  }.property('progress'),

  manuscriptUploadUrl: function() {
    return '/api/papers/' + this.get('model.paper.id') + '/upload';
  }.property('model.paper.id'),

  actions: {
    uploadProgress: function(data) {
      this.set('progress', Math.round((data.loaded / data.total) * 100));

      if(this.get('progress') >= 100) {
        setTimeout(()=> {
          this.setProperties({showProgress: false, isProcessing: true});
        }, 500);
      }
    },

    uploadError: function(message) {
      this.set('uploadError', message);
    },

    uploadFinished: function(data, filename) {
      this.uploadFinished(data, filename);
      this.store.pushPayload(data);

      this.get('model').save().then(()=> {
        this.send('closeAction');
      });
    }
  }
});
