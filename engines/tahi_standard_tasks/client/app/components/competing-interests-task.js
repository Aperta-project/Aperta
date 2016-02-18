import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';

const { computed } = Ember;

export default TaskComponent.extend({
  declareNoCompeteCopy:
    'The authors have declared that no competing interests exist.',

  competingInterestsStatementQuestion(){
    return this.get('task').findQuestion('competing_interests--statement');
  },

  setCompetingInterestStatement(text) {
    const question = this.competingInterestsStatementQuestion();
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
