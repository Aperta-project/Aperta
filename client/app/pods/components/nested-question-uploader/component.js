import NestedQuestionComponent from 'tahi/pods/components/nested-question/component';
import FileUpload from 'tahi/models/file-upload';

export default NestedQuestionComponent.extend({
  fileUpload: null,
  displayContent: true,

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

    uploadFinished: function(uploadUrl) {
      let answer = this.get('model.answer');
      answer.set('value', uploadUrl);
      return answer.save().then( () => {
        this.set('fileUpload', null);
      });
    },

    destroyAttachment: function(attachment) {
      return this.sendAction('destroyAttachment', attachment);
    }
  }
});
