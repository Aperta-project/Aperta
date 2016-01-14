import Ember from 'ember';
import NestedQuestionComponent from 'tahi/pods/components/nested-question/component';

export default NestedQuestionComponent.extend({
  attachments: Ember.computed('model.answer.attachment', function() {
    return [this.get('model.answer.attachment')].compact();
  }),

  actions: {
    updateAttachment(s3Url, file, attachment) {
     this.get('model.answer').set('value', s3Url).save();
    },

    deleteAttachment(attachment){
     attachment.destroyRecord();
    }
  }
});
