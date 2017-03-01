import TaskComponent from 'tahi/pods/components/task-base/component';

export default TaskComponent.extend({
  declareNoCompeteCopy: 'The authors have declared that no competing interests exist.',
  setCompetingInterestStatement(text) {
    let answer = this
      .get('store')
      .peekCardContent('competing_interests--statement')
      .answerForOwner(this.get('task'));
    answer.set('value', text);
    answer.save();
  },
  actions: {
    userSelectedNo() {
      this.setCompetingInterestStatement(this.get('declareNoCompeteCopy'));
    },
    userSelectedYes() {
      this.setCompetingInterestStatement('');
    }
  }
});
