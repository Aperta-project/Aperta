import Ember from 'ember';

export default Ember.Component.extend({
  isTextItem:     Ember.computed.equal('item.type', 'text'),
  isCheckboxItem: Ember.computed.equal('item.type', 'checkbox'),
  isEmailItem:    Ember.computed.equal('item.type', 'email'),
  isSendable: true,

  // attrs
  item: null,
  block: null,
  editing: false,
  allUsers: null,
  overlayParticipants: null,
  emailSentStates: null,
  isNew: false,
  // deleteItem
  // deleteBlock
  // saveModel
  // sendEmail

  actions: {
    deleteItem(item) {
      this.attrs.deleteItem(item, this.get('block'));
    },

    deleteBlock() {
      this.attrs.deleteBlock(this.get('block'));
    }
  }
});
