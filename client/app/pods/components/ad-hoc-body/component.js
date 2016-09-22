import Ember from 'ember';
import { task as concurrencyTask, timeout } from 'ember-concurrency';


let isNotEmpty = (item) => {
  return item && Ember.isPresent(item.value);
};


let BlockObject = Ember.Object.extend({
  items: null,
  snapshot: null,
  isNew: false,

  type: Ember.computed.reads('items.firstObject.type'),
  hasContent: Ember.computed('items.@each.value', function() {
    return this.get('items').any(isNotEmpty);
  }),

  createSnapshot() {
    this.set('snapshot', Ember.copy(this.get('items'), true));
  },

  revertToSnapshot() {
    this.set('items', Ember.copy(this.get('snapshot'), true));
  },

  addItem(attrs) {
    this.get('items').pushObject(attrs);
  },

  init() {
    this._super(...arguments);
    this.set('snapshot', []);
  },

  pruneEmptyItems() {
    this.set('items', this.get('items').reject(function(item) {
      return Ember.isEmpty(item.value);
    }));
  }
});

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
  canManage: true,

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
  emailSentStates: Ember.computed(() => { return []; }),

  blocks: null,
  blockObjects: Ember.computed('blocks.[]', function() {
    return this.get('blocks').map((block) => {
      return BlockObject.create({items: block});
    });
  }),

  blockSort: ['isNew:asc'],
  displayedBlocks: Ember.computed.sort('blockObjects', 'blockSort'),
  hasNewBlock: Ember.computed('blockObjects.@each.isNew', function() {
    return this.get('blockObjects').isAny('isNew');
  }),

  addBlock(firstItemAttrs) {
    this.get('blockObjects').pushObject(
      BlockObject.create({
        isNew: true,
        items: [firstItemAttrs]
      })
    );
  },

  actions: {
    setTitle(title) {
      this.set('title', title);
    },

    addLabel(){
      this.addBlock({
        type: 'adhoc-label',
        value: ''
      });
    },

    addTextBlock() {
      this.addBlock({
        type: 'text',
        value: ''
      });
    },

    addChecklist() {
      this.addBlock({
        type: 'checkbox',
        value: '',
        answer: false
      });
    },

    addEmail() {
      this.addBlock({
        type: 'email',
        subject: '',
        value: '',
        sent: ''
      });
    },

    saveBlock(block) {
      block.set('isNew', false);

      block.pruneEmptyItems();

      this.get('save')(this.get('persistedBlocks'));
    },

    resetBlock(block) {
      if (block.get('isNew')) {
        this.get('blockObjects').removeObject(block);
      } else {
        block.revertToSnapshot();
      }
    },

    addCheckboxItem(block) {
      return block.addItem({
        type: 'checkbox',
        value: '',
        answer: false
      });
    },

    deleteItem(item, block) {
      block.removeObject(item);
      if (!block.get('hasContent')) {
        this.send('deleteBlock', block);
      }

      if (!block.get('isNew')) {
        this.get('save')(this.get('persistedBlocks'));
      }
    },

    deleteBlock(block) {
      this.get('blockObjects').removeObject(block);

      if (!block.get('isNew')) {
        this.get('save')(this.get('persistedBlocks'));
      }
    },

    //ad hoc task stuff
    sendEmail(data) {
      this.get('restless').putModel(this.get('task'), '/send_message', {
        task: data
      });

      this.get('save')(this.get('persistedBlocks'));
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
