import DS from 'ember-data';

export default DS.Model.extend({
  date: DS.attr('string'),
  subject: DS.attr('string'),
  recipient: DS.attr('string'),
  sender: DS.attr('string'),
});
