import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  name: DS.attr('string'),
  state: DS.attr('string'),
  dispatchAt: DS.attr('date'),
  completed: Ember.computed.equal('state', 'completed'),
  errored: Ember.computed.equal('state', 'errored'),
  inactive: Ember.computed.equal('state', 'inactive'),
  finished: DS.attr('boolean')
});
