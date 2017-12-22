import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  createdAt: DS.attr('date'),
  confirmationState: DS.attr('string'),
  coauthors: DS.attr(),
  paperTitle: DS.attr('string'),
  journalLogoUrl: DS.attr('string'),
  isConfirmable: Ember.computed.equal('confirmationState', 'unconfirmed'),
  isConfirmed: Ember.computed.equal('confirmationState', 'confirmed')
});
