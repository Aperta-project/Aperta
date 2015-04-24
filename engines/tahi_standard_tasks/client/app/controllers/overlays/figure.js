import TaskController from 'tahi/pods/task/controller';
import FileUploadMixin from 'tahi/mixins/file-upload';

export default TaskController.extend(FileUploadMixin, {
  figureUploadUrl: function() {
    return `/api/papers/${this.get('model.litePaper.id')}/figures`;
  }.property('model.litePaper.id'),

  figures: function() {
    return (this.get('model.paper.figures') || [])
              .sortBy('createdAt').reverse();
  }.property('model.paper.figures.[]', 'model.paper.figures.@each.createdAt'),

  actions: {
    uploadFinished(data, filename) {
      this.uploadFinished(data, filename);
      this.store.pushPayload('figure', data);

      let figure = this.store.getById('figure', data.figure.id);
      this.get('model.paper.figures').pushObject(figure);
    },

    changeStrikingImage(newValue) {
      this.get('model.paper').set('strikingImageId', newValue);
    },

    updateStrikingImage() {
      this.get('model.paper').save();
    },

    destroyAttachment(attachment) {
      this.get('model.paper.figures').removeObject(attachment);
      attachment.destroyRecord();
    }
  }
});
