import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  paper: DS.belongsTo('paper'),

  firstName: DS.attr('string'),
  lastName: DS.attr('string'),
  position: DS.attr('number'),

  fullName: Ember.computed('firstName', 'middleInitial', 'lastName', function() {
    return [this.get('firstName'), this.get('middleInitial'), this.get('lastName')].compact().join(' ');
  })
});
