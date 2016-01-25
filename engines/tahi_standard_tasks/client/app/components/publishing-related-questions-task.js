import TaskComponent from 'tahi/pods/components/task-base/component';

export default TaskComponent.extend({
  publishedElsewhereRelatedWorkQuestion: Ember.computed('task', function(){
    return this.get('task')
      .findQuestion('publishing_related_questions--published_elsewhere--upload_related_work');
  }),

  actions: {
    savePaperShortTitle() {
      this.get('task.paper').save();
    }
  }
});
