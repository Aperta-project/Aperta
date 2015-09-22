import Ember from 'ember';
import NestedQuestionOwner from 'tahi/models/nested-question-owner';
import DS from 'ember-data';

let a = DS.attr;

export default NestedQuestionOwner.extend({
  // qualifiedType: 'TahiStandardTask::ReviewerRecommendation',

  firstName: a('string'),
  middleInitial: a('string'),
  lastName: a('string'),
  email: a('string'),
  title: a('string'),
  department: a('string'),
  affiliation: a('string'),
  ringgoldId: a('string'),
  recommendOrOppose: a('string'),
  reason: a('string'),
  reviewerRecommendationsTask: DS.belongsTo('reviewerRecommendationsTask'),

  fullName: function() {
    return [this.get('firstName'), this.get('middleInitial'), this.get('lastName')].compact().join(' ');
  }.property('firstName', 'middleInitial', 'lastName')
});
