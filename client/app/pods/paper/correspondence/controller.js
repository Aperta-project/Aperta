import Ember from 'ember';

export default Ember.Controller.extend({
  correspondence: Ember.computed.alias('model'),
  sortedSentAt: Ember.computed.sort('correspondence', 'sortDefinition'),
  sortDefinition: ['sentAt']
});
