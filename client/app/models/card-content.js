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

  allowMultipleUploads: DS.attr('boolean'),
  allowFileCaptions: DS.attr('boolean'),
  contentType: DS.attr('string'),
  ident: DS.attr('string'),
  placeholder: DS.attr('string'),
  possibleValues: DS.attr(),
  order: DS.attr('number'),
  text: DS.attr('string'),
  label: DS.attr('string'),
  valueType: DS.attr('string'),
  visibleWithParentAnswer: DS.attr('string'),
  answerable: Ember.computed.notEmpty('valueType'),

  childrenSort: ['order:asc'],
  children: Ember.computed.sort('unsortedChildren', 'childrenSort'),

  createAnswerForOwner(owner){
    // only create answers for things that are actually
    // answerable (i.e., textboxes, radio buttons) and
    // not things like static text or paragraphs
    if(this.get('answerable')) {
      return this.get('store').createRecord('answer', {
        owner: owner,
        cardContent: this
      });
    } else {
      return null;
    }
  },

  answerForOwner(owner) {
    return this.get('answers').findBy('owner', owner) ||
           this.createAnswerForOwner(owner);
  }
});
