import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['admin-tab-bar'],
  featureFlag: Ember.inject.service(),

  cardConfigEnabled: Ember.computed(function() {
    return this.get('featureFlag').value('CARD_CONFIGURATION');
  }),

  emailTemplateEnabled: Ember.computed(function() {
    return this.get('featureFlag').value('EMAIL_TEMPLATE');
  })
});
