import DS from 'ember-data';

export default DS.Model.extend({
  text: DS.attr('string'),
  templateDecision: DS.attr('string'),
  to: DS.attr('string'),
  subject: DS.attr('string'),
  letter: DS.attr('string')
});
