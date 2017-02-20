import Ember from 'ember';
import DS from 'ember-data';
import DependentRelationships from 'tahi/mixins/dependent-relationships';

export default DS.Model.extend(DependentRelationships, {
  journal: DS.belongsTo('admin-journal', { async: false }),
  phaseTemplates: DS.hasMany('phase-template', { async: false }),
  activePapers: DS.hasMany('paper'),
  activePaperCount: Ember.computed('activePapers.length', function(){
    // determine number of active papers without fetching them
    return this.hasMany('activePapers').ids().length;
  }),
  paperType: DS.attr('string'),
  usesResearchArticleReviewerReport: DS.attr('boolean'),
  updatedAt: DS.attr('date')
});
