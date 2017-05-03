import Ember from 'ember';
import DS from 'ember-data';

const {
  computed,
  isEmpty
} = Ember;

export default DS.Model.extend({
  similarityChecks: DS.hasMany('similarity-check'),
  paper: DS.belongsTo('paper'),
  text: DS.attr('string'),
  majorVersion: DS.attr(),
  minorVersion: DS.attr(),
  updatedAt: DS.attr('date'),
  versionString: DS.attr('string'),
  fileType: DS.attr('string'),
  isDraft: computed('majorVersion', 'minorVersion', function() {
    return isEmpty(this.get('majorVersion')) && isEmpty(this.get('minorVersion'));
  }),
  sourceType: DS.attr('string'),

  hasSimilarityChecks: Ember.computed('similarityChecks.[]', function() {
    return 0 < this.get('similarityChecks.length');
  }),
});
