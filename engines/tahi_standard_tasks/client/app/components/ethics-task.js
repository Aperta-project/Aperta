import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';

const { computed } = Ember;

export default TaskComponent.extend({
  humanSubjectsQuestion: computed('task', function(){
    return this.get('task')
               .findQuestion('ethics--human_subjects');
  }),

  participantsQuestion: computed('task', function(){
    return this.get('task')
               .findQuestion('ethics--human_subjects--participants');
  }),

  animalSubjectsQuestion: computed('task', function(){
    return this.get('task')
               .findQuestion('ethics--animal_subjects');
  }),

  fieldPermitQuestion: computed('task', function(){
    return this.get('task')
               .findQuestion('ethics--animal_subjects--field_permit');
  }),

  fieldStudyQuestion: computed(function(){
    return this.get('task')
              .findQuestion('ethics--field_study');
  }),

  fieldPermitNumberQuestion: computed(function(){
    return this.get('task')
               .findQuestion('ethics--field_study--field_permit_number');
  }),

  actions: {
    destroyAttachment(attachment) {
      attachment.destroyRecord();
    },

    userSelectedNoOnHumanSubjects() {
      const question = this.get('participantsQuestion');
      const answer = question.answerForOwner(this.get('task'));
      answer.set('value', '');
      answer.save();
    },

    userSelectedNoOnAnimalSubjects() {
      const question = this.get('fieldPermitQuestion');
      const answer = question.answerForOwner(this.get('task'));
      answer.set('value', '');
      answer.save();
    },

    userSelectedNoOnFieldStudy(){
      const question = this.get('fieldStudyQuestion');
      const answer = question.answerForOwner(this.get('task'));
      answer.set('value', '');
      answer.save();
    }
  }
});
