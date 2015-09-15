import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  paper: DS.belongsTo('paper', { async: false }),
  authorsTask: DS.belongsTo('authorsTask'),

  firstName: DS.attr('string'),
  middleInitial: DS.attr('string'),
  lastName: DS.attr('string'),
  email: DS.attr('string'),
  title: DS.attr('string'),
  department: DS.attr('string'),

  affiliation: DS.attr('string'),
  ringgoldId: DS.attr('string'),

  secondaryAffiliation: DS.attr('string'),
  secondaryRinggoldId: DS.attr('string'),

  corresponding: DS.attr('boolean'),
  deceased: DS.attr('boolean'),
  position: DS.attr('number'),
  contributions: DS.attr(),

  position: DS.attr('number'),

  fullName: Ember.computed('firstName', 'middleInitial', 'lastName', function() {
    return [this.get('firstName'), this.get('middleInitial'), this.get('lastName')].compact().join(' ');
  })
});
