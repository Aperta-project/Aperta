import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  token: DS.attr('string'),
  created_at: DS.attr('date'),
  confirmationState: DS.attr('string'),
  coauthors: DS.attr(),
  paper_title: DS.attr('string'),
  journal_logo_url: DS.attr('string'),
  isConfirmable: Ember.computed.equal('confirmationState', 'unconfirmed')
});
