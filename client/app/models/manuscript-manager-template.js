import DS from 'ember-data';
import DependentRelationships from 'tahi/mixins/dependent-relationships';

export default DS.Model.extend(DependentRelationships, {
  journal: DS.belongsTo('admin-journal', { async: false }),
  phaseTemplates: DS.hasMany('phase-template', { async: false }),
  paperType: DS.attr('string'),
  usesResearchArticleReviewerReport: DS.attr('boolean')
});
