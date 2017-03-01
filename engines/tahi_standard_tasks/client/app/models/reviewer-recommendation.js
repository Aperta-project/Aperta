import NestedQuestionOwner from 'tahi/models/nested-question-owner';
import Answerable from 'tahi/mixins/answerable';
import DS from 'ember-data';

let a = DS.attr;

const validations = {
  firstName: ['presence'],
  lastName: ['presence'],
  email: ['presence', 'email']
};

export default NestedQuestionOwner.extend(Answerable, {
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
  validations: validations,

  fullName: function() {
    return [this.get('firstName'), this.get('middleInitial'), this.get('lastName')].compact().join(' ');
  }.property('firstName', 'middleInitial', 'lastName'),

});
