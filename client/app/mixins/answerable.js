import Ember from 'ember';
import DS from 'ember-data';

// Answerable is intended to be mixed into DS.Model instances
export default Ember.Mixin.create({
  card: DS.belongsTo('card'),
  answers: DS.hasMany('answers'),
  ownerTypeForAnswer: DS.attr('string'),

  // findCardContent assumes that the CardContent with the given ident
  // is already loaded into the store.
  // it's the new version of NestedQuestionOwner's findQuestion function
  findCardContent(ident) {
    return this.get('store').peekCardContent(ident);
  },

  // answerForIdent assumes that the neccessary models are already loaded into
  // the store.
  // it's the new version of NestedQuestionOwner's answerForQuestion function
  answerForIdent(ident) {
    let store = this.get('store');
    return store.peekAnswer(ident, this) ||
      store.createRecord('answer', {
        owner: this,
        cardContent: store.peekCardContent(ident)
      });
  },

  // Answerables keep track of specific things they need to display. ex: the Authors
  // task needs to load the 'Author' and 'GroupAuthor' cards in order to display new
  // authors.
  fetchRelationships() {
    return Ember.RSVP.all([this.get('card'), this.get('answers')]);
  }
});
