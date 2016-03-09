import Ember from 'ember';
import { contributionIdents } from 'tahi/authors-task-validations';

export default Ember.Component.extend({
  classNames: ['add-author-form'],
  author: null,

  authorContributionIdents: contributionIdents,

  resetAuthor() {
    this.get('author').rollback();
  },

  actions: {
    cancelEdit() {
      this.resetAuthor();
      this.sendAction('hideAuthorForm');
    },

    saveNewAuthor() {
      this.sendAction('saveAuthor', this.get('author'));
    },

    validateField(key, value) {
      if(this.attrs.validateField) {
        this.attrs.validateField(key, value);
      }
    }
  }
});
