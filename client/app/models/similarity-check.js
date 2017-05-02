import DS from 'ember-data';
import Ember from 'ember';


export default DS.Model.extend({
  versionedText: DS.belongsTo('versioned-text'),
  paper: DS.belongsTo('paper'),
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
      inProgress: 'is in progress',
      failed: 'has failed',
      delivered: 'succeeded'
    }[this.get('state')];
  })
});
