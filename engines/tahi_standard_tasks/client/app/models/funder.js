import Ember from 'ember';
import NestedQuestionOwner from 'tahi/models/nested-question-owner';
import DS from 'ember-data';

export default NestedQuestionOwner.extend({
  additionalComments: DS.attr('string'),
  task: DS.belongsTo('financialDisclosureTask'),
  authors: DS.hasMany('author'),
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
  }).property('website'),

  onlyHasAdditionalComments: Ember.computed(
      'additionalComments',
      'name',
      'website',
      'grantNumber',
      function() {
        const additionalComments = this.get('additionalComments');
        const name = this.get('name');
        const website = this.get('website');
        const grantNumber = this.get('grantNumber');
        return !!(additionalComments && !name && !website && !grantNumber);
  })

});
