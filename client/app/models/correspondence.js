import DS from 'ember-data';
import Ember from 'ember';
// import fontAwesomeFiletypeClass from 'tahi/lib/font-awesome-fyletype-class';

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

  manuscriptVersionStatus: Ember.computed('manuscriptVersion','manuscriptStatus', function() {
    if (!this.get('manuscriptVersion') || !this.get('manuscriptStatus')) {
      return 'Unavailable';
    }
    else {
      return this.get('manuscriptVersion') + ' ' + this.get('manuscriptStatus');
    }
  }),

  // checkFileType: Ember.computed('attachments.@each', function() {
  //   // console.log(this.get('attachments.@each.filename'));
  //   // return fontAwesomeFiletypeClass(this.get('attachments.filename'));
  // }),

  allAttachments: Ember.computed('attachment', function(){
    return this.get('attachments');
  }),

  hasAnyAttachment: Ember.computed('attachments', function() {
    return Ember.isEmpty(this.get('attachments'));
  })
});
