import Ember from 'ember';
import CardContentQuestion from
  'tahi/pods/components/card-content-question/component';
import { task as concurrencyTask, timeout } from 'ember-concurrency';

export default CardContentQuestion.extend({
  multiple: false,

  store: Ember.inject.service(),

  attachments: Ember.computed.alias('answer.attachments'),

  // Do not propagate to parent component as this component is in charge
  // of saving itself (otherwise the parent component may issue another
  // attempt to save the attachment).
  change: function(){
    return false;
  },

  cancelUpload: concurrencyTask(function * (attachment) {
    yield attachment.cancelUpload();
    yield timeout(5000);
    attachment.unloadRecord();
  }),

  actions: {

    cancelUpload(attachment) {
      this.get('cancelUpload').perform(attachment);
    },

    updateAttachment(s3Url, file, attachment) {
      Ember.assert(s3Url, 'Must provide an s3Url');
      Ember.assert(file, 'Must provide a file');

      const answer = this.get('answer');
      const store =  this.get('store');
      answer.save().then( (savedAnswer) => {
        if(!attachment){
          attachment = store.createRecord('question-attachment');
          savedAnswer.get('attachments').addObject(attachment);
        }
        attachment.setProperties({
          src: s3Url,
          filename: file.name
        });
        //TODO APERTA-8972 this is where the QuestionAttachmentsController gets hit
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
