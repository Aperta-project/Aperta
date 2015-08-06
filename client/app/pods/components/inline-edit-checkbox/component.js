import Ember from 'ember';

export default Ember.Component.extend({
  editing: false,
  isNew: false,
  bodyPart: null,
  bodyPartType: Ember.computed.alias('bodyPart.type'),

  checked: Ember.computed('bodyPart.answer', {
    get() {
      let answer = this.get('bodyPart.answer');
      return answer === 'true' || answer === true;
    },
    set(key, value) {
      return this.set('bodyPart.answer', value);
    }
  }),

  actions: {
    saveChanges() {
      this.attrs.save();
    },

    deleteItem() {
      this.attrs['delete']();
    }
  }
});
