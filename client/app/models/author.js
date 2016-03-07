import Ember from 'ember';
import DS from 'ember-data';
import NestedQuestionOwner from 'tahi/models/nested-question-owner';

const { attr, belongsTo } = DS;

export default NestedQuestionOwner.extend({
  paper: belongsTo('paper', { async: false }),
  task: belongsTo('task'),

  authorInitial: attr('string'),
  firstName: attr('string'),
  middleInitial: attr('string'),
  lastName: attr('string'),
  email: attr('string'),
  title: attr('string'),
  department: attr('string'),

  currentAddressStreet: attr('string'),
  currentAddressStreet2: attr('string'),
  currentAddressCity: attr('string'),
  currentAddressState: attr('string'),
  currentAddressCountry: attr('string'),
  currentAddressPostal: attr('string'),

  affiliation: attr('string'),
  ringgoldId: attr('string'),

  secondaryAffiliation: attr('string'),
  secondaryRinggoldId: attr('string'),

  position: attr('number'),
  corresponding: attr('boolean'),
  deceased: attr('boolean'),

  fullName: Ember.computed('firstName', 'middleInitial', 'lastName', function() {
    return [
      this.get('firstName'),
      this.get('middleInitial'),
      this.get('lastName')
    ].compact().join(' ');
  })
});
