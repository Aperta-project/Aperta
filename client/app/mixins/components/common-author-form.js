import Ember from 'ember';

export default Ember.Mixin.create({
  author: null,
  authorProxy: null,
  validationErrors: Ember.computed.alias('authorProxy.validationErrors'),

  resetAuthor() {
    this.get('author').rollbackAttributes();
  },

  saveAuthor() {
    this.get('author').save().then(() => {
      this.get('saveSuccess')();
    });
  },

  actions: {
    cancelEdit() {
      this.resetAuthor();
      this.sendAction('hideAuthorForm');
    },

    saveAuthor() {
      this.saveAuthor();
    },
    validateField(key, value) {
      if(this.get('validateField')) {
        this.get('validateField')(key, value);
      }
    }
  }
});
