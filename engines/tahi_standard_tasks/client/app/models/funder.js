import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  task: DS.belongsTo('financialDisclosureTask'),
  authors: DS.hasMany('author'),
  funderHadInfluence: DS.attr('boolean'),
  funderInfluenceDescription: DS.attr('string'),
  grantNumber: DS.attr('string'),
  name: DS.attr('string'),
  relationshipsToSerialize: ['authors'],
  website: DS.attr('string'),

  formattedWebsite: (function() {
    var website;
    website = this.get('website');
    if (Ember.isEmpty(website)) {
      return null;
    }
    if (/https?:\/\//.test(website)) {
      return website;
    }
    return "http://" + website;
  }).property('website')
});
