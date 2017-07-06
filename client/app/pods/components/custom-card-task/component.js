import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';

export default TaskComponent.extend({
  contentRoot: Ember.computed.alias('task.cardVersion.contentRoot'),

  hasAdditionalText: Ember.computed('task.nestedQuestions.[]', function() {
    let cardContents = this.get('task.cardVersion.contentRoot.unsortedChildren');
    return cardContents.any((cardContent) => {
      return cardContent.hasAdditionalText;
    });
  }),
});
