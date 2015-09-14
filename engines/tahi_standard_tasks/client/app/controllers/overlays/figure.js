import TaskController from 'tahi/pods/paper/task/controller';
import FileUploadMixin from 'tahi/mixins/file-upload';

export default TaskController.extend(FileUploadMixin, {
  figureUploadUrl: function() {
    return `/api/papers/${this.get('model.paper.id')}/figures`;
  }.property('model.paper.id'),

  figures: function() {
    return (this.get('model.paper.figures') || [])
              .sortBy('createdAt').reverse();
  }.property('model.paper.figures.[]', 'model.paper.figures.@each.createdAt'),

  figureCompliesQuestion: Ember.computed('model', function(){
    return this.get('model').findQuestion('figure_complies');
  }),

  actions: {
    uploadFinished(data, filename) {
      this.uploadFinished(data, filename);
      this.store.pushPayload('figure', data);
    },

    changeStrikingImage(newValue) {
      this.get('model.paper').set('strikingImageId', newValue);
      this.get('model.paper').save();
    },

    updateStrikingImage() {
      this.get('model.paper').save();
    },

    destroyAttachment(attachment) {
      attachment.destroyRecord();
    }
  }
});
