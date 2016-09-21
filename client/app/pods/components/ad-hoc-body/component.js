import Ember from 'ember';
import { task as concurrencyTask, timeout } from 'ember-concurrency';

export default Ember.Component.extend({
  store: Ember.inject.service(),
  restless: Ember.inject.service(),
  hasAttachments: Ember.computed.notEmpty('task.attachments'),
  showAttachments: false,
  showAttachmentsBlock: Ember.computed.or('hasAttachments', 'showAttachments'),
  participants: Ember.computed.mapBy('task.participations', 'user'),

  attachmentsPath: Ember.computed('task.id', function() {
    return `/api/tasks/${this.get('task.id')}/attachments`;
  }),

  paperId: Ember.computed('task', function() {
    return this.get('task.paper.id');
  }),

  canEdit: true,
  canFillOut: false,

  attachmentsRequest(path, method, s3Url, file) {
    const store = this.get('store');
    const restless = this.get('restless');
    restless.ajaxPromise(method, path, {url: s3Url}).then((response) => {
      response.attachment.filename = file.name;
      store.pushPayload(response);
    });
  },

  cancelUpload: concurrencyTask(function * (attachment) {
    yield attachment.cancelUpload();
    yield timeout(5000);
    attachment.unloadRecord();
  }),

  // BuildsTaskTemplate stuff
  newBlocks: Ember.computed(() => { return []; }),
  blocks: null,
  emailSentStates: Ember.computed(() => { return []; }),

  isNew(block) {
    return this.get('newBlocks').contains(block);
  },

  replaceBlock(block, otherBlock) {
    let blocks = this.get('blocks');
    let position = blocks.indexOf(block);

    if (position !== -1) {
      blocks.replace(position, 1, [otherBlock]);
      blocks.enumerableContentDidChange();
    }
  },

  _pruneEmptyItems(block) {
    return block.reject(function(item) {
      return Ember.isEmpty(item.value);
    });
  },

  actions: {
    setTitle(title) {
      this.set('title', title);
      this.get('save')();
    },

    addLabel(){
      this.get('newBlocks').pushObject([{
        type: 'adhoc-label',
        value: ''
      }]);
    },

    addTextBlock() {
      this.get('newBlocks').pushObject([{
        type: 'text',
        value: ''
      }]);
    },

    addChecklist() {
      this.get('newBlocks').pushObject([{
        type: 'checkbox',
        value: '',
        answer: false
      }]);
    },

    addEmail() {
      this.get('newBlocks').pushObject([{
        type: 'email',
        subject: '',
        value: '',
        sent: ''
      }]);
    },

    saveBlock(block) {
      if (this.isNew(block)) {
        this.get('blocks').pushObject(block);
        this.get('newBlocks').removeObject(block);
      }

      this.replaceBlock(block, this._pruneEmptyItems(block));

      this.get('save')();
    },

    resetBlock(block, snapshot) {
      if (this.isNew(block)) {
        this.get('newBlocks').removeObject(block);
      } else {
        this.replaceBlock(block, snapshot);
      }
    },

    addCheckboxItem(block) {
      return block.pushObject({
        type: 'checkbox',
        value: '',
        answer: false
      });
    },

    deleteItem(item, block) {
      block.removeObject(item);
      if (Ember.isEmpty(block)) {
        this.send('deleteBlock', block);
      }

      if (!this.isNew(block)) {
        this.get('save')();
      }
    },

    deleteBlock(block) {
      if (this.isNew(block)) {
        this.get('newBlocks').removeObject(block);
      } else {
        this.get('blocks').removeObject(block);
        this.get('save')();
      }
    },

    //ad hoc task stuff
    sendEmail(data) {
      this.get('restless').putModel(this.get('task'), '/send_message', {
        task: data
      });

      this.get('save')();
    },

    updateAttachmentCaption(caption, attachment) {
      attachment.set('caption', caption);
      attachment.save();
    },

    updateAttachment(s3Url, file, attachment) {
      const path = `${this.get('attachmentsPath')}/${attachment.id}/update_attachment`;
      this.attachmentsRequest(path, 'PUT', s3Url, file);
    },

    createAttachment(s3Url, file) {
      this.attachmentsRequest(this.get('attachmentsPath'), 'POST', s3Url, file);
    },

    deleteAttachment(attachment) {
      attachment.destroyRecord();
    },

    cancelUpload(attachment) {
      this.get('cancelUpload').perform(attachment);
    },

    uploadFailed(reason) {
      throw new Ember.Error(`Upload from browser to s3 failed: ${reason}`);
    },

    addAttachmentsBlock() {
      this.set('showAttachments', true);
    }
  }
});
