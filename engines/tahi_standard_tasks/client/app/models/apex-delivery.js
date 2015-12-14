import DS from 'ember-data';
import Ember from 'ember';


export default DS.Model.extend({
  paper: DS.belongsTo('paper', { async: true }),
  task: DS.belongsTo('send-to-apex-task', {
    inverse: 'apexDeliveries',
    async: true }),
  state: DS.attr('string'),
  errorMessage: DS.attr('string'),
  createdAt: DS.attr('date'),

  failed: Ember.computed.equal('state', 'failed'),
  succeeded: Ember.computed.equal('state', 'delivered'),
  incomplete: Ember.computed('state', function() {
    let state = this.get('state');
    return state !== 'delivered' && state !== 'failed';
  }),

  humanReadableState: Ember.computed('state', function() {
    return {
      pending: 'is pending',
      in_progress: 'is in progress',
      failed: 'has failed',
      delivered: 'succeeded'
    }[this.get('state')];
  })
});
