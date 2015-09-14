import TaskController from 'tahi/pods/paper/task/controller';
import SavesQuestionsOnClose from 'tahi/mixins/saves-questions-on-close';

export default TaskController.extend(SavesQuestionsOnClose, {
  humanSubjectsQuestion: Ember.computed("model", function(){
    return this.get("model").findQuestion("human_subjects");
  }),

  participantsQuestion: Ember.computed("model", function(){
    return this.get("model").findQuestion("human_subjects.participants");
  }),

  animalSubjectsQuestion: Ember.computed("model", function(){
    return this.get("model").findQuestion("animal_subjects");
  }),

  fieldPermitQuestion: Ember.computed("model", function(){
    return this.get("model").findQuestion("animal_subjects.field_permit");
  }),

  actions: {
    destroyAttachment: function(attachment){
      attachment.destroyRecord();
    },

    userSelectedNoOnHumanSubjects: function(){
      let answer = this.get("participantsQuestion.answer");
      answer.set("value", "");
      answer.save();
    },

    userSelectedNoOnAnimalSubjects: function(){
      let answer = this.get("fieldPermitQuestion.answer");
      answer.set("value", "");
      answer.save();
    },
  }
});
