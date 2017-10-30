import DS from 'ember-data';
import Ember from 'ember';


export default DS.Model.extend({
  paper: DS.belongsTo('paper', { async: true }),
  task: DS.belongsTo('task', {
    inverse: 'exportDeliveries',
    polymorphic: true
  }),
  state: DS.attr('string'),
  errorMessage: DS.attr('string'),
  createdAt: DS.attr('date'),
  destination: DS.attr('string'),

  failed: Ember.computed.equal('state', 'failed'),
  succeeded: Ember.computed('state', function() {
    let state = this.get('state');
    return state === 'delivered' || state === 'preprint_posted';
  }),
  incomplete: Ember.computed('state', function() {
    let state = this.get('state');
    return state === 'pending' || state === 'in_progress';
  }),
  published: Ember.computed.equal('state', 'preprint_posted'),

  preprintDoiAssigned: Ember.computed('destination', 'paper.aarxDoi', function(){
    let ppDoi = this.get('paper.aarxDoi');
    let preprintDoiExists = ppDoi !== undefined && ppDoi !== null && ppDoi.length > 0;
    return this.get('destination') === 'preprint' && preprintDoiExists;
  }),

  exportDoi: Ember.computed('paper.aarxDoi', 'paper.doi', 'destination', function() {
    if (this.get('destination') === 'preprint') {
      return this.get('paper.aarxDoi');
    } else {
      return this.get('paper.doi');
    }
  }),

  humanReadableState: Ember.computed('state', function() {
    return {
      pending: 'is pending',
      in_progress: 'is in progress',
      failed: 'has failed',
      delivered: 'succeeded',
      preprint_posted: 'succeeded'
    }[this.get('state')];
  })
});
