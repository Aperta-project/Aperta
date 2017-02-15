import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  contentRoot: DS.belongsTo('card-content'),
  cardContent: DS.hasMany('card-content'),
  name: DS.attr('string')
});
