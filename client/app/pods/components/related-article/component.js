import Ember from 'ember';

export default Ember.Component.extend({
  relatedArticle: null, // Pass me in, please
  editable: true,       // Pass me in, please

  classNames: ['related-article'],
  classNameBindings: ['editable', 'editState:editing', 'idClass'],

  idClass: Ember.computed('relatedArticle.id', function() {
    return 'related-article-' + this.get('relatedArticle.id');
  }),

  editState: Ember.computed('relatedArticle.isNew', function() {
    return this.get('relatedArticle.isNew');
  }),

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
