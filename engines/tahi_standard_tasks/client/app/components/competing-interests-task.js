import TaskComponent from 'tahi/pods/components/task-base/component';
import SavesQuestionsOnClose from 'tahi/mixins/saves-questions-on-close';
import Ember from 'ember';

const { computed } = Ember;

export default TaskComponent.extend(SavesQuestionsOnClose, {
  declareNoCompeteCopy:
    'The authors have declared that no competing interests exist.',

  anyCompetingInterestsQuestion: computed(function(){
    return this.get('task').findQuestion('competing_interests');
  }),

  competingInterestsStatementQuestion: computed(function(){
    return this.get('task').findQuestion('competing_interests.statement');
  }),

  setCompetingInterestStatement(text) {
    const question = this.get('competingInterestsStatementQuestion');
    const answer = question.answerForOwner(this.get('task'));
    answer.set('value', text);
    answer.save();
  },

  actions: {
    userSelectedNo(){
      this.setCompetingInterestStatement(this.get('declareNoCompeteCopy'));
    },

    userSelectedYes() {
      this.setCompetingInterestStatement('');
    }
  }
});
