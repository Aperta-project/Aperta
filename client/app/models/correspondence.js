import DS from 'ember-data';
import Ember from 'ember';

export default DS.Model.extend({
  paper: DS.belongsTo('paper', { async: false }),
  attachments: DS.hasMany('correspondence-attachment', { async: false }),
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
  activities: DS.attr(), // array?

  manuscriptVersionStatus: Ember.computed('manuscriptVersion','manuscriptStatus', function() {
    if (!this.get('manuscriptVersion') || !this.get('manuscriptStatus')) {
      return 'Unavailable';
    }
    else {
      return this.get('manuscriptVersion') + ' ' + this.get('manuscriptStatus');
    }
  }),

  hasAnyAttachment: Ember.computed('attachments', function() {
    return (this.get('attachments').length !== 0);
  }),

  hasActivities: Ember.computed.notEmpty('activities'),
});
