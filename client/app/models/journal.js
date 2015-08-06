import DS from 'ember-data';

export default DS.Model.extend({
  reviewers: DS.hasMany('user', { async: false }),
  logoUrl: DS.attr('string'),
  manuscriptCss: DS.attr('string'),
  name: DS.attr('string'),
  paperTypes: DS.attr()
});
