import Ember from 'ember';
import NestedQuestionComponent from 'tahi/pods/components/nested-question/component';

export default NestedQuestionComponent.extend({
  multiple: false,

  attachments: Ember.computed('model.answer.attachment', function() {
    return this.get('model.answer.attachments');
  }),

  // Do not propagate to parent component as this component is in charge
  // of saving itself (otherwise the parent component may issue another
  // attempt to save the attachment).
  change: function(){
    return false;
  },

  actions: {
    updateAttachment(s3Url, file, attachment) {
      Ember.assert(s3Url, "Must provide an s3Url");
      Ember.assert(file, "Must provide a file");

      if(!attachment){
        attachment = this.container.lookup("store:main").createRecord("question-attachment");
        this.get('model.answer.attachments').addObject(attachment);
      }
      attachment.setProperties({
        src: s3Url,
        filename: file.name
      });
      attachment.save();
    },

    updateAttachmentTitle(title, attachment) {
      attachment.set('title', title);
      attachment.save();
    },

    deleteAttachment(attachment){
     attachment.destroyRecord();
    }
  }
});
