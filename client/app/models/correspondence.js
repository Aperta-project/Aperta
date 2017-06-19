import DS from 'ember-data';

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
  sentAt: DS.attr('date')
});
