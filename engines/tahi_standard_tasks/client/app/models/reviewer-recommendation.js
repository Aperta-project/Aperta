import DS from 'ember-data';

var a = DS.attr;

export default DS.Model.extend({
  // qualifiedType: 'TahiStandardTask::ReviewerRecommendation',

  firstName: a('string'),
  middleInitial: a('string'),
  lastName: a('string'),
  email: a('string'),
  title: a('string'),
  department: a('string'),
  affiliation: a('string'),
  recommendOrOppose: a('string'),
  reviewerRecommendationsTask: DS.belongsTo('reviewerRecommendationsTask'),

  fullName: function() {
    return [this.get('firstName'), this.get('middleInitial'), this.get('lastName')].compact().join(' ');
  }.property('firstName', 'middleInitial', 'lastName')
});
