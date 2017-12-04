import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  name: DS.attr('string'),
  state: DS.attr('string'),
  dispatchAt: DS.attr('date'),
  finished: DS.attr('boolean'),
  dueDatetime: DS.belongsTo('due_datetime'),

  completed: Ember.computed.equal('state', 'completed'),
  errored: Ember.computed.equal('state', 'errored'),
  inactive: Ember.computed.equal('state', 'inactive'),
  active: Ember.computed.equal('state', 'active'),
  canceled: Ember.computed.equal('state', 'canceled')
});
