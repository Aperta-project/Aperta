import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  topic: DS.belongsTo('discussion-topic'),
  replier: DS.belongsTo('user'),

  body: DS.attr('string')
});
