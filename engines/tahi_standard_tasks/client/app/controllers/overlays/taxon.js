import TaskController from 'tahi/pods/paper/task/controller';
import SavesQuestionsOnClose from 'tahi/mixins/saves-questions-on-close';

var TaxonOverlayController;

TaxonOverlayController = TaskController.extend(SavesQuestionsOnClose, {
  taxonQuestionForZoological: Ember.computed(function(){
    return this.get('model').findQuestion('taxon_zoological');
  }),

  compliesQuestionForZoological: Ember.computed(function(){
    return this.get('model').findQuestion('taxon_zoological.complies');
  }),

  taxonQuestionForBotanical: Ember.computed(function(){
    return this.get('model').findQuestion('taxon_botanical');
  }),

  compliesQuestionForBotanical: Ember.computed(function(){
    return this.get('model').findQuestion('taxon_botanical.complies');
  })
});

export default TaxonOverlayController;
