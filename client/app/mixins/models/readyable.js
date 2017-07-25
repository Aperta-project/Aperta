import Ember from 'ember';
import DS from 'ember-data';

export default Ember.Mixin.create({
  ready: DS.attr('boolean'),
  readyIssues: DS.attr(),
  hasErrors: Ember.computed.notEmpty('readyIssuesArray'),

  readyIssuesArray: Ember.computed('readyIssues.[]', function(){
    return this.getWithDefault('readyIssues', []);
  })
});
