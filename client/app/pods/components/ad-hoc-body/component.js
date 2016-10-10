import Ember from 'ember';

let isNotEmpty = (item) => {
  return item && Ember.isPresent(item.value);
};


let BlockObject = Ember.Object.extend({
  items: null,
  snapshot: null,
  isNew: false,
  index: null,

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
  paperId: Ember.computed.reads('task.paper.id'),

  canEdit: true,
  canManage: true,

  // BuildsTaskTemplate stuff
  emailSentStates: Ember.computed(() => { return []; }),

  blocks: null,
  blockObjects: Ember.computed('blocks.[]', function() {
    return this.get('blocks').map((block, idx) => {
      // note that items are shared by reference here.
      // that means that when one of the items' 'value' property
      // is updated, it will update item in the blocks array too.
      // we should probably make it such that the block items are copied
      // rather than shared, as it makes things way more confusing.
      return BlockObject.create({items: block, index: idx});
      //
    });
  }),

  blockSort: ['isNew:asc', 'index:asc'],
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
    // You'll see several instances of us mutating the `blockObjects`
    // array throughout this component.  `blockObjects` is a computed property
    // that will retain its cached value until an item is added or removed from the
    // passed-in `blocks` array; it acts as our working set of changes to the blocks.
    // Remember that in practice calling `this.get('blockObjects')` multiple times will
    // always return a reference to the same array until the `blocks.[]` key is invalidated,
    // so you can trust the `blockObjects` reference to stay consistent until you add
    // or remove a block, at which point it will recompute and return a fresh array

    let newIndex = this.get('blockObjects.length');
    this.get('blockObjects').pushObject(
      BlockObject.create({
        isNew: isNew,
        index: newIndex,
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
