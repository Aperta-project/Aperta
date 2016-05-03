import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['related-article'],
  relatedArticle: null, // Pass me in, please
  editState: false,

  actions: {
    edit: function() {
      this.set('editState', true);
    },

    cancelEdit: function() {
      this.get('relatedArticle').rollback();
      this.set('editState', false);
    },

    save: function() {
      this.get('relatedArticle').save();
      this.set('editState', false);
    },

    delete: function() {
      this.get('relatedArticle').destroyRecord();
    }
  }
});
