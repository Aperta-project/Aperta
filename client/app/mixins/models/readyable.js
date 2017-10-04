import Ember from 'ember';
import DS from 'ember-data';

export default Ember.Mixin.create({
  ready: DS.attr('boolean'),
  readyIssues: DS.attr(),
  hasErrors: Ember.computed.notEmpty('readyIssuesArray'),

  initiallyHideErrors: function() {
    this.set('hideErrors', true);
  },

  shouldShowErrors: Ember.computed('readyIssues.[]', 'hideErrors', function() {
    return !this.get('hideErrors') && this.get('hasErrors')
  }),

  readyIssuesArray: Ember.computed('readyIssues.[]', function(){
    return this.getWithDefault('readyIssues', []);
  })
});
