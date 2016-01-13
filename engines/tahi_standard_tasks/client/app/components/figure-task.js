import TaskComponent from 'tahi/pods/components/task-base/component';
import FileUploadMixin from 'tahi/mixins/file-upload';
import Ember from 'ember';

export default TaskComponent.extend(FileUploadMixin, {
  figureUploadUrl: Ember.computed('task.paper.id', function() {
    return '/api/papers/' + this.get('task.paper.id') + '/figures';
  }),

  figures: Ember.computed(
    'task.paper.figures.[]', 'task.paper.figures.@each.createdAt', function() {
      return (this.get('task.paper.figures') || [])
                .sortBy('createdAt').reverse();
    }
  ),

  actions: {
    uploadFinished(data, filename) {
      this.uploadFinished(data, filename);
      this.store.pushPayload('figure', data);
    },

    destroyAttachment(attachment) {
      attachment.destroyRecord();
    }
  }
});
