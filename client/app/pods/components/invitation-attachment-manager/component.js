import Ember from 'ember';

export default Ember.Component.extend({
  multiple: false,

  store: Ember.inject.service(),


  actions: {
    updateAttachment(s3Url, file, attachment) {
      Ember.assert(s3Url, 'Must provide an s3Url');
      Ember.assert(file, 'Must provide a file');

      answer.save().then( (savedAnswer) => {
        if(!attachment){
          attachment = store.createRecord('question-attachment');
          savedAnswer.get('attachments').addObject(attachment);
        }
        attachment.setProperties({
          src: s3Url,
          filename: file.name
        });
        attachment.save();
      });
    },

    updateAttachmentCaption(caption, attachment) {
      attachment.set('caption', caption);
      attachment.save();
    },

    deleteAttachment(attachment){
      attachment.destroyRecord();
    }
  }
});
