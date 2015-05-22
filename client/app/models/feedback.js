import DS from 'ember-data';

export default DS.Model.extend({
  referrer: DS.attr('string'),
  remarks: DS.attr('string'),
  screenshots: DS.attr()
});
