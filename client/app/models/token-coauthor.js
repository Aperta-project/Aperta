import Ember from 'ember';
import DS from 'ember-data';
import moment from 'moment';

export default DS.Model.extend({
  created_at: DS.attr('date'),
  confirmationState: DS.attr('string'),
  coauthors: DS.attr(),
  paper_title: DS.attr('string'),
  journal_logo_url: DS.attr('string'),
  isConfirmable: Ember.computed.equal('confirmationState', 'unconfirmed'),
  isConfirmed: Ember.computed.equal('confirmationState', 'confirmed')
});
