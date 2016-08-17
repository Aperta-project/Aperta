import Ember from 'ember';

export default Ember.Mixin.create({
  newBlocks: [],
  blocks: null,
  emailSentStates: null,

  _init: Ember.on('init', function() {
    this.set('newBlocks', []);
  }),

  setEmailStates: Ember.on('init', function() {
    this.set('emailSentStates', Ember.ArrayProxy.create({
      content: []
    }));
  }),

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
    },

    deleteBlock(block) {
      if (this.isNew(block)) {
        this.get('newBlocks').removeObject(block);
      } else {
        this.get('blocks').removeObject(block);
      }
    }
  }
});
