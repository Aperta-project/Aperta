import DS from 'ember-data';

export default DS.Model.extend({
  paper: DS.belongsTo('paper', { async: false }),

  alt: DS.attr('string'),
  filename: DS.attr('string'),
  src: DS.attr('string'),
  status: DS.attr('string'),
  title: DS.attr('string'),
  category: DS.attr('string'),
  label: DS.attr('string'),
  caption: DS.attr('string'),
  publishable: DS.attr('boolean')
});
