import Ember from 'ember';
import { task as concurrencyTask, timeout } from 'ember-concurrency';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  propTypes: {
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool,
    answer: PropTypes.EmberObject.isRequired
  },

  store: Ember.inject.service(),

  // Do not propagate to parent component as this component is in charge of
  // saving itself (otherwise the parent component may issue another attempt to
  // save the attachment). Remember that 'change' intercepts the change event
  // from any child DOM element.
  change: function() {
    return false;
  },

  cancelUpload: concurrencyTask(function*(attachment) {
    yield attachment.cancelUpload();
    yield timeout(5000);
    attachment.unloadRecord();
  }),

  acceptedFileTypes: Ember.computed.mapBy('content.possibleValues', 'value'),

  actions: {
    cancelUpload(attachment) {
      this.get('cancelUpload').perform(attachment);
    },

    updateAttachment(s3Url, file, attachment) {
      Ember.assert(s3Url, 'Must provide an s3Url');
      Ember.assert(file, 'Must provide a file');

      const answer = this.get('answer');
      const store = this.get('store');
      answer.save().then(savedAnswer => {
        if (!attachment) {
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

    deleteAttachment(attachment) {
      attachment.destroyRecord();
    }
  }
});
