import Ember from 'ember';
import DS from 'ember-data';

// Answerable is intended to be mixed into DS.Model instances
export default Ember.Mixin.create({
  card: DS.belongsTo('card'),
  answers: DS.hasMany('answers'),
  ownerTypeForAnswer: DS.attr('string'),
});
