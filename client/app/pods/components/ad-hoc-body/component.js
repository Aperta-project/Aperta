import Ember from 'ember';

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

  removeItem(item) {
    this.get('items').removeObject(item);
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
  restless: Ember.inject.service(),
  participants: Ember.computed.mapBy('task.participations', 'user'),
  toolbarActive: false,
  paperId: Ember.computed('task', function() {
    return this.get('task.paper.id');
  }),

  canEdit: true,
  canManage: true,

  // BuildsTaskTemplate stuff
  emailSentStates: Ember.computed(() => { return []; }),

  blocks: null,
  blockObjects: Ember.computed('blocks.[]', function() {
    return this.get('blocks').map((block) => {
      // note that items are shared by reference here.
      // that means that when one of the items' 'value' property
      // is updated, it will update item in the blocks array too.
      // we should probably make it such that the block items are copied
      // rather than shared, as it makes things way more confusing.
      return BlockObject.create({items: block});
      //
    });
  }),

  blockSort: ['isNew:asc'],
  displayedBlocks: Ember.computed.sort('blockObjects', 'blockSort'),
  hasNewBlock: Ember.computed('blockObjects.@each.isNew', function() {
    return this.get('blockObjects').isAny('isNew');
  }),

  saveBlocks() {
    let blockPath = this.get('isEditingTemplate') ? 'template' : 'body';
    this.get('task').set(blockPath, this.get('displayedBlocks').mapBy('items'));
    this.get('save')();
  },

  addBlock(firstItemAttrs, isNew = true) {
    this.get('blockObjects').pushObject(
      BlockObject.create({
        isNew: isNew,
        items: [firstItemAttrs]
      })
    );
  },

  actions: {
    toggleToolbar() {
      this.toggleProperty('toolbarActive');
      if (this.get('hasNewBlock')) {
        this.set('toolbarActive', false);
      }
    },

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
      }, false);
      this.saveBlocks();
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

    addAttachments() {
      if(!this.get('blockObjects').isAny('type', 'attachments')){
        this.addBlock({
          type: 'attachments',
          value: 'Please select a file.'
        }, false);
        this.saveBlocks();
      }
    },

    saveBlock(block) {
      block.set('isNew', false);

      block.pruneEmptyItems();

      this.saveBlocks();
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
      block.removeItem(item);
      if (!block.get('hasContent')) {
        this.send('deleteBlock', block);
      }

      if (!block.get('isNew')) {
        this.saveBlocks();
      }
    },

    deleteBlock(block) {
      this.get('blockObjects').removeObject(block);

      if (!block.get('isNew')) {
        this.saveBlocks();
      }
    },

    //ad hoc task stuff
    sendEmail(data) {
      this.get('restless').putModel(this.get('task'), '/send_message', {
        task: data
      });

      this.saveBlocks();
    }
  }
});
