import DS from 'ember-data';
import Ember from 'ember';


export default DS.Model.extend({
  majorVersion: DS.attr('number'),
  minorVersion: DS.attr('number'),
  contents: DS.attr(),
  createdAt: DS.attr('date'),
  fullVersion: Ember.computed('majorVersion', 'minorVersion', function() {
    return `${this.get('majorVersion')}.${this.get('minorVersion')}`;
  }),

  versionString: Ember.computed(
    'fullVersion', 'createdAt',
    function() {
      return `R${this.get('fullVersion')}`;
    }),

  hasDiff(otherSnapshot) {
    let string1 = JSON.stringify(this.get('contents'));
    let string2 = JSON.stringify(otherSnapshot.get('contents'));
    return string1 !== string2;
  }
});
