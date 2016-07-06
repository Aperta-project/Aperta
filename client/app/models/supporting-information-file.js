import DS from 'ember-data';
import Snapshottable from 'tahi/mixins/snapshottable';

export default DS.Model.extend(Snapshottable, {
  paper: DS.belongsTo('paper', { async: false }),

  alt: DS.attr('string'),
  filename: DS.attr('string'),
  src: DS.attr('string'),
  status: DS.attr('string'),
  title: DS.attr('string'),
  category: DS.attr('string'),
  label: DS.attr('string'),
  caption: DS.attr('string'),
  publishable: DS.attr('boolean'),
  strikingImage: DS.attr('boolean')  
});
