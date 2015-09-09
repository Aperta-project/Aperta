import DS from 'ember-data';

let a = DS.attr;

export default DS.Model.extend({
  paper: DS.belongsTo('paper'),
  plosAuthorsTask: DS.belongsTo('plosAuthorsTask'),

  qualifiedType: 'PlosAuthors::PlosAuthor',

  firstName: a('string'),
  middleInitial: a('string'),
  lastName: a('string'),
  email: a('string'),
  title: a('string'),
  department: a('string'),

  affiliation: a('string'),
  ringgoldId: a('string'),

  secondaryAffiliation: a('string'),
  secondaryRinggoldId: a('string'),

  corresponding: a('boolean'),
  deceased: a('boolean'),
  position: a('number'),
  contributions: a(),

  addContribution: function(contributionId, value){
    let contribution = {id: contributionId, value: value};
    this.get('contributions').addObject(contribution);
  },

  removeContribution: function(contributionId){
    let contributions = this.get('contributions');
    contributions.removeObject(contributions.findBy("id", contributionId));
  },

  fullName: function() {
    return [this.get('firstName'), this.get('middleInitial'), this.get('lastName')].compact().join(' ');
  }.property('firstName', 'middleInitial', 'lastName')
});
