import NestedQuestionComponent from 'tahi/pods/components/nested-question/component';
import FileUpload from 'tahi/models/file-upload';

export default NestedQuestionComponent.extend({
  fileUpload: null,

  actions: {
    uploadStarted: function(data) {
      return this.set('fileUpload', FileUpload.create({
        file: data.files[0]
      }));
    },

    uploadProgress: function(data) {
      return this.get('fileUpload').setProperties({
        dataLoaded: data.loaded,
        dataTotal: data.total
      });
    },

    uploadFinished: function(data) {
      let answerValue = this.get('model.answer.value') || {};
      this.set('model.answer.value', _.extend(answerValue, {url: data}));
      return this.get('model.answer').save().then( () => {
        this.set('fileUpload', null);
      });
    },

    destroyAttachment: function(attachment) {
      return this.sendAction('destroyAttachment', attachment);
    }
  }
});
