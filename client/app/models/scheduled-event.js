import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  name: DS.attr('string'),
  state: DS.attr('string'),
  dispatchAt: DS.attr('date'),
  completed: Ember.computed.equal('state', 'completed'),
  errored: Ember.computed.equal('state', 'errored'),
  inactive: Ember.computed.equal('state', 'inactive'),
  active: Ember.computed.equal('state', 'active'),
  finished: DS.attr('boolean'),
  restless: Ember.inject.service(),
  updateState: function(newState) {
    const url = `/api/scheduled_events/${this.get('id')}/${newState}`;
    return this.get('restless').get(url).then(() => {
      // set the class to reflect the new state
    });
  }
});
