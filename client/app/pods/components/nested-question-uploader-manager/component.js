import Ember from 'ember';
import getOwner from 'ember-getowner-polyfill';
import NestedQuestionComponent from 'tahi/pods/components/nested-question/component';

export default NestedQuestionComponent.extend({
  multiple: false,

  store: Ember.inject.service(),

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
      Ember.assert(s3Url, 'Must provide an s3Url');
      Ember.assert(file, 'Must provide a file');

      const answer = this.get('model.answer');
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
