import DS from 'ember-data';

export default DS.Model.extend({
  paper: DS.belongsTo('paper', { async: false }),
  date: DS.attr('string'),
  subject: DS.attr('string'),
  recipient: DS.attr('string'),
  sender: DS.attr('string'),
  body: DS.attr('string'),
  sentAt: DS.attr('string'),
});
