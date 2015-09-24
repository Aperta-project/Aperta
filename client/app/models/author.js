import Ember from 'ember';
import DS from 'ember-data';
import NestedQuestionOwner from 'tahi/models/nested-question-owner';

export default NestedQuestionOwner.extend({
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

  position: DS.attr('number'),
  corresponding: DS.attr('boolean'),
  deceased: DS.attr('boolean'),

  fullName: Ember.computed('firstName', 'middleInitial', 'lastName', function() {
    return [this.get('firstName'), this.get('middleInitial'), this.get('lastName')].compact().join(' ');
  })
});
