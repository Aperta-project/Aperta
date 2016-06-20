import TaskComponent from 'tahi/pods/components/task-base/component';
import FileUploadMixin from 'tahi/mixins/file-upload';
import Ember from 'ember';

export default TaskComponent.extend(FileUploadMixin, {
  figureUploadUrl: Ember.computed('task.paper.id', function() {
    return '/api/papers/' + this.get('task.paper.id') + '/figures';
  }),

  figures: Ember.computed(
     'task.paper.figures.@each.rank', function() {
      return (this.get('task.paper.figures') || [])
                .sortBy('rank');
    }
  ),

  actions: {
    uploadFinished(data, filename) {
      this.uploadFinished(data, filename);
    },

    destroyFigure(figure) {
      figure.destroyRecord();
    },

    // get updated paper text with figure inserted
    processingFinished() {
      this.get('task.paper').reload();
    }
  }
});
