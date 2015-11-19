import DS from 'ember-data';
import Ember from 'ember';
import formatDate from 'tahi/lib/format-date';


export default DS.Model.extend({
  paper: DS.belongsTo('paper', { async: true }),
  text: DS.attr('string'),
  majorVersion: DS.attr(),
  minorVersion: DS.attr(),
  updatedAt: DS.attr('date'),
  versionString: Ember.computed(
    'majorVersion',
    'minorVersion',
    'updatedAt',
    function() {
      let date = formatDate(this.get('updatedAt'), {format: 'MMM DD, YYYY'});
      let version = `R${this.get('majorVersion')}.${this.get('minorVersion')}`;
      return `${version} - ${date}`;
    }
  )
});
