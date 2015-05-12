import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  invitations: DS.hasMany('invitation'),
  paper: DS.belongsTo('paper'),
  questions: DS.hasMany('question'),

  createdAt: DS.attr('date'),
  isLatest: DS.attr('boolean'),
  letter: DS.attr('string'),
  revisionNumber: DS.attr('number'),
  verdict: DS.attr('string'),

  revisionHumanNumber: Ember.computed('revisionNumber', function() {
    return this.get('revisionNumber') + 1;
  })
});
