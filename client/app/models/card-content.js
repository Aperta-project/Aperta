import DS from 'ember-data';
import Ember from 'ember';

export default DS.Model.extend({
  unsortedChildren: DS.hasMany('card-content', {
    inverse: 'parent',
    async: false
  }),
  parent: DS.belongsTo('card-content', {
    async: false,
    inverse: 'unsortedChildren'
  }),
  answers: DS.hasMany('answer', { async: false }),

  contentType: DS.attr('string'),
  ident: DS.attr('string'),
  placeholder: DS.attr('string'),
  possibleValues: DS.attr(),
  order: DS.attr('number'),
  text: DS.attr('string'),
  valueType: DS.attr('string'),
  visibleWithParentAnswer: DS.attr('string'),

  childrenSort: ['order:asc'],
  children: Ember.computed.sort('unsortedChildren', 'childrenSort'),

  answerForOwner(owner) {
    return this.get('answers').findBy('owner', owner) ||
      this.get('store').createRecord('answer', {
        owner: owner,
        cardContent: this
      });
  }
});
