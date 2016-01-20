import Ember from 'ember';
import NestedQuestionComponent from 'tahi/pods/components/nested-question/component';

export default NestedQuestionComponent.extend({
  multiple: false,

  attachments: Ember.computed('model.answer.attachment', function() {
    return this.get('model.answer.attachments');
  }),

  actions: {
    updateAttachment(s3Url, file, attachment) {
      if(attachment){
        attachment.setProperties({
          src: s3Url,
          filename: file.name
        });
        attachment.save();
      }
      else {
        let attachments = this.get('model.answer.attachments');
        var a = this.container.lookup("store:main").createRecord("question-attachment", {
          src: s3Url,
          filename: file.name
        });
        attachments.addObject(a);
        a.save();
      }
    },

    deleteAttachment(attachment){
     attachment.destroyRecord();
    }
  }
});
