import DS from 'ember-data';

let a = DS.attr;

export default DS.Model.extend({
  paper: DS.belongsTo('paper'),
  alt: a('string'),
  filename: a('string'),
  src: a('string'),
  status: a('string'),
  title: a('string'),
  caption: a('string'),
  detailSrc: DS.attr('string'),
  previewSrc: DS.attr('string'),

  // when a file is loaded via the event stream the paper's
  // hasMany relationship isn't automatically updated.  This
  // is a somewhat well-known ember data bug. we need to manually
  // update the relationship for now.
  updatePaperFiles: function() {
    this.get('paper.supportingInformationFiles').addObject(this);
  }.on('didLoad')
});
