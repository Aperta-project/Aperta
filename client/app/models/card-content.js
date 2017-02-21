import DS from 'ember-data';

export default DS.Model.extend({
  children: DS.hasMany('card-content', { inverse: 'parent' }),
  parent: DS.belongsTo('card-content'),
  answers: DS.hasMany('answer', { async: false }),

  ident: DS.attr('string'),
  text: DS.attr('string'),
  valueType: DS.attr('string'),

  answerForOwner(owner) {
    return this.get('answers').findBy('owner', owner) ||
    this.get('store').createRecord('answer', {
      owner: owner,
      cardContent: this
    });
  }
});
