import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  reviewers: DS.hasMany('user', { async: false }),
  logoUrl: DS.attr('string'),
  manuscriptCss: DS.attr('string'),
  name: DS.attr('string'),
  staffEmail: DS.attr('string'),
  paperTypes: DS.attr(),
  pdfAllowed: DS.attr('boolean'),

  initials: Ember.computed('name', function() {
    return this.get('name').split(' ').map(s => s[0]).join('');
  })
});
