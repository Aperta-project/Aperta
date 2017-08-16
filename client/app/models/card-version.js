import DS from 'ember-data';
import Ember from 'ember';

export default DS.Model.extend({
  card: DS.belongsTo('card'),
  contentRoot: DS.belongsTo('card-content', { async: false }),
  publishedAt: DS.attr('date'),
  historyEntry: DS.attr('string'),
  publishedBy: DS.attr('string'),

  isPublished: Ember.computed.notEmpty('publishedAt')
});
