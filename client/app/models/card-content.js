import DS from 'ember-data';
import Ember from 'ember';


export default DS.Model.extend({
  unsortedChildren: DS.hasMany('card-content', { inverse: 'parent', async: false }),
  parent: DS.belongsTo('card-content'),
  answers: DS.hasMany('answer', { async: false }),

  ident: DS.attr('string'),
  text: DS.attr('string'),
  valueType: DS.attr('string'),
  contentType: DS.attr('string'),
  order: DS.attr('number'),

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
