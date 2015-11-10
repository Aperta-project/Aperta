import DS from 'ember-data';
import Ember from 'ember';


export default DS.Model.extend({
  majorVersion: DS.attr('number'),
  minorVersion: DS.attr('number'),
  contents: DS.attr(),
  createdAt: DS.attr('date'),

  versionString: Ember.computed(
    'majorVersion', 'minorVersion', 'createdAt',
    function() {
      return `R${this.get('majorVersion')}.${this.get('minorVersion')}`;
    })
});
