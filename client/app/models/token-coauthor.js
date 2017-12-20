import DS from 'ember-data';

export default DS.Model.extend({
  token: DS.attr('string'),
  paper_title: DS.attr('string'),
  coauthors: DS.attr()
});
