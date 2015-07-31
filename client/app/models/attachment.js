import DS from 'ember-data';

export default DS.Model.extend({
  task: DS.belongsTo('task'),
  caption: DS.attr('string'),
  filename: DS.attr('string'),
  kind: DS.attr('string'),
  previewSrc: DS.attr('string'),
  src: DS.attr('string'),
  status: DS.attr('string'),
  title: DS.attr('string')
});
