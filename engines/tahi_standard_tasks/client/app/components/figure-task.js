import TaskComponent from 'tahi/pods/components/task-base/component';
import FileUploadMixin from 'tahi/mixins/file-upload';
import Ember from 'ember';

export default TaskComponent.extend(FileUploadMixin, {
  figureUploadUrl: Ember.computed('task.paper.id', function() {
    return '/api/papers/' + this.get('task.paper.id') + '/figures';
  }),

  figures: Ember.computed(
    'task.paper.figures.@each.rank', function() {
      let allFigs = this.get('task.paper.figures');
      let figs = allFigs.rejectBy('status', 'uploading');
      if (Ember.isPresent(figs)) {
        let labelled = figs.filterBy('rank').sortBy('rank');
        let unlabelled = figs.rejectBy('rank');
        return labelled.concat(unlabelled);
      } else {
        return [];
      }
    }
  ),

  figureUpdateUrlFunc(figureId) {
    return '/api/figures/' + figureId + '/update_attachment';
  },

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
    },

    uploadFailed(data) {
      this.unloadUploads({}, data.files[0].name);
    }

  }
});
