import DS from 'ember-data';
import Ember from 'ember';
import formatDate from 'tahi/lib/format-date';

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
  activities: DS.attr(),
  status: DS.attr('string'),
  additionalContext: DS.attr(),

  isDeleted: Ember.computed('status', 'external', function() {
    return this.get('status') === 'deleted';
  }),
  isActive: Ember.computed.not('isDeleted'),

  utcSentAt: Ember.computed('sentAt', 'status', function() {
    if (this.get('status') === 'deleted') return '';

    let sentAt = this.get('sentAt');
    let time = Ember.isBlank(sentAt) ? moment.utc() : moment.utc(sentAt);
    return time.format('MMMM D, YYYY HH:mm');
  }),

  manuscriptVersionStatus: Ember.computed('manuscriptVersion','manuscriptStatus', function() {
    let version_status = this.get('manuscriptVersion') + ' ' + this.get('manuscriptStatus');
    version_status = version_status.replace('null','').trim();

    if (version_status === 'null') {
      return 'Unavailable';
    }
    else {
      return version_status;
    }
  }),

  hasAnyAttachment: Ember.computed('attachments', function() {
    return (this.get('attachments').length !== 0);
  }),

  hasActivities: Ember.computed.notEmpty('activities'),

  activityNames: {
    'correspondence.created': 'Added',
    'correspondence.edited': 'Edited',
    'correspondence.deleted': 'Deleted'
  },

  activityMessages: Ember.computed.map('activities', function(activity) {
    return `${this.get('activityNames')[activity.key]} by ${activity.full_name} on ${formatDate(activity.created_at, { format: 'long-date-military-time' })}`;
  }),

  lastActivityMessage: Ember.computed('activityMessages', function(){
    return this.get('activityMessages.firstObject');
  })
});
