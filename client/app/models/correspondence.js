import DS from 'ember-data';
import Ember from 'ember';

export default DS.Model.extend({
  paper: DS.belongsTo('paper', { async: false }),
  date: DS.attr('string'),
  subject: DS.attr('string'),
  recipients: DS.attr('string'),
  recipient: DS.attr('string'),
  sender: DS.attr('string'),
  body: DS.attr('string'),
  external: DS.attr('boolean', { defaultValue: false }),
  description: DS.attr('string'),
  cc: DS.attr('string'),
  bcc: DS.attr('string'),
  sentAt: DS.attr('date'),
  manuscriptVersion: DS.attr('string'),
  manuscriptStatus: DS.attr('string'),

  manuscriptVersionStatus: Ember.computed('manuscriptVersion','manuscriptStatus', function() {
    return this.get('manuscriptVersion') + ' ' + this.get('manuscriptStatus');
  }),
});