import Ember from 'ember';

export default Ember.Mixin.create({
  editing: Ember.computed.alias('parentView.editing'),
  isNew: false,
  bodyPart: null,
  bodyPartType: Ember.computed.alias('bodyPart.type'),

  actions: {
    deleteItem() {
      return this.sendAction('delete', this.get('bodyPart'));
    }
  }
});
