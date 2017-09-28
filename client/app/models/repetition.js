import DS from 'ember-data';

export default DS.Model.extend({
  cardContent: DS.belongsTo('card-content'),
  task: DS.belongsTo('task'),
  answers: DS.hasMany('answer', { async: false }),
  unsortedChildren: DS.hasMany('repetition', { inverse: 'parent', async: false }),
  parent: DS.belongsTo('repetition', { inverse: 'unsortedChildren', async: false }),

  childrenSort: ['order:asc'],
  children: Ember.computed.sort('unsortedChildren', 'childrenSort'),

  cascadingDestroy() {
    this.get('children').invoke('cascadingDestroy');
    this.get('answers').invoke('destroyRecord');
    this.destroyRecord();
  },
});
