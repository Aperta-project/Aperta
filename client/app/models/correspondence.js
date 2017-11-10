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
  activities: DS.attr(), // array?

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
  activityMessages: Ember.computed('activities', function() {
    return this.get('activities').map((activity) => {
      let result = '';
      if (activity.activity_key === 'correspondence.created') {
        result += 'Added by ';
      } else {
        result += 'Edited by ';
      }
      result += activity.full_name + ' on ' + formatDate(activity.created_at, { format: 'MMMM DD, YYYY kk:mm' });
      return result;
    });
  }),
});
