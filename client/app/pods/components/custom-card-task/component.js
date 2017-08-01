import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';

export default TaskComponent.extend({
  contentRoot: Ember.computed.reads('task.cardVersion.contentRoot'),

  renderAdditionalText: Ember.computed('task.cardVersion.contentRoot', function() {
    return this.containsAdditionalText(this.get('task.cardVersion.contentRoot'));
  }),
  containsAdditionalText: function(cardContent) {
    if (!cardContent.get('unsortedChildren').length) {
      return cardContent.get('renderAdditionalText');
    } else {
      return cardContent.get('unsortedChildren').any((cc) => {
        return this.containsAdditionalText(cc);
      });
    }
  }
});
