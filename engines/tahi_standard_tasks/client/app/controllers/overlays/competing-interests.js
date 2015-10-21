import TaskController from 'tahi/pods/paper/task/controller';
import SavesQuestionsOnClose from 'tahi/mixins/saves-questions-on-close';
var CompetingInterestsOverlayController;

CompetingInterestsOverlayController = TaskController.extend(SavesQuestionsOnClose, {
  declareNoCompeteCopy: "The authors have declared that no competing interests exist.",

  anyCompetingInterestsQuestion: Ember.computed(function(){
    return this.get('model').findQuestion('competing_interests');
  }),

  competingInterestsStatementQuestion: Ember.computed(function(){
    return this.get('model').findQuestion('competing_interests.statement');
  }),

  setCompetingInterestStatement: function(text) {
    let question = this.get("competingInterestsStatementQuestion");
    let answer = question.answerForOwner(this.get("model"));
    answer.set('value', text);
    answer.save();
  },

  actions: {
    userSelectedNo: function(){
      this.setCompetingInterestStatement(this.get('declareNoCompeteCopy'));
    },
    userSelectedYes: function() {
      this.setCompetingInterestStatement('');
    }
  }
});

export default CompetingInterestsOverlayController;
