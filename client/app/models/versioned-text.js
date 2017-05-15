import Ember from 'ember';
import DS from 'ember-data';

const {
  computed,
  isEmpty
} = Ember;

export default DS.Model.extend({
  paper: DS.belongsTo('paper', { async: true }),
  text: DS.attr('string'),
  majorVersion: DS.attr(),
  minorVersion: DS.attr(),
  updatedAt: DS.attr('date'),
  versionString: DS.attr('string'),
  fileType: DS.attr('string'),
  isDraft: computed('majorVersion', 'minorVersion', function() {
    return isEmpty(this.get('majorVersion')) && isEmpty(this.get('minorVersion'));
  }),
  sourceType: DS.attr('string')
});
