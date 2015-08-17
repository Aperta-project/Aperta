import DS from 'ember-data';

let a = DS.attr;

export default DS.Model.extend({
  paper: DS.belongsTo('paper', { async: false }),

  alt: a('string'),
  filename: a('string'),
  src: a('string'),
  status: a('string'),
  title: a('string'),
  caption: a('string'),
  detailSrc: DS.attr('string'),
  previewSrc: DS.attr('string'),
  publishable: DS.attr('boolean')
});
