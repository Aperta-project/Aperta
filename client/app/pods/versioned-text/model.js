import Ember from 'ember';
import DS from 'ember-data';
import moment from 'moment';

const {
  computed,
  isEmpty,
  isBlank
} = Ember;

export default DS.Model.extend({
  similarityChecks: DS.hasMany('similarity-check'),
  paper: DS.belongsTo('paper'),
  text: DS.attr('string'),
  majorVersion: DS.attr(),
  minorVersion: DS.attr(),
  updatedAt: DS.attr('date'),
  fileType: DS.attr('string'),
  isDraft: computed('majorVersion', 'minorVersion', function() {
    return isEmpty(this.get('majorVersion')) && isEmpty(this.get('minorVersion'));
  }),
  sourceType: DS.attr('string'),
  versionString: computed('majorVersion', 'minorVersion', 'updatedAt', function() {
    const date = moment(this.get('updatedAt')).format('MMM DD, YYYY');
    const fileType = isBlank(this.get('fileType')) ? '' : `(${this.get('fileType').toUpperCase()})`;
    if (this.get('isDraft')) {
      return`(draft) ${fileType} - ${date}`;
    }
    return`v${this.get('majorVersion')}.${this.get('minorVersion')} ${fileType} - ${date}`;
  }),

  hasSimilarityChecks: Ember.computed.notEmpty('similarityChecks'),
});
