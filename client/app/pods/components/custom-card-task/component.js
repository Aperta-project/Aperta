import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';

export default TaskComponent.extend({
  contentRoot: Ember.computed.alias('task.cardVersion.contentRoot'),

  renderAdditionalText: Ember.computed('task.cardVersion.contentRoot.unsortedChildren.[]', function() {
    let cardContents = this.get('task.cardVersion.contentRoot.unsortedChildren');
    return cardContents.any((cardContent) => {
      return cardContent.get('renderAdditionalText');
    });
  }),
});
