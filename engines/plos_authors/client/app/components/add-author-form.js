import Ember from 'ember';

export default Ember.Component.extend({
  layoutName: 'components/add-author-form',

  setNewAuthor: function() {
    if (!this.get('newAuthor')) {
      this.set('newAuthor', {});
    }
  }.on('init'),

  clearNewAuthor: function() {
    if (Ember.typeOf(this.get('newAuthor')) === 'object') {
      this.set('newAuthor', {});
    }
  },

  selectableInstitutions: function() {
    return (this.get('institutions') || []).map(function(institution) {
      return {
        id: institution,
        text: institution
      };
    });
  }.property('institutions'),

  selectedAffiliation: function() {
    return {
      id: this.get('newAuthor.affiliation'),
      text: this.get('newAuthor.affiliation')
    };
  }.property('newAuthor'),

  selectedSecondaryAffiliation: function() {
    return {
      id: this.get('newAuthor.secondaryAffiliation'),
      text: this.get('newAuthor.secondaryAffiliation')
    };
  }.property('newAuthor'),

  actions: {
    cancelEdit: function() {
      this.clearNewAuthor();
      this.sendAction('hideAuthorForm');
    },

    saveNewAuthor: function() {
      this.sendAction('saveAuthor', this.get('newAuthor'));
      this.clearNewAuthor();
    }
  }
});
