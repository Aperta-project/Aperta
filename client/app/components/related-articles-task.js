import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';

export default TaskComponent.extend({
  classNames: ['related-articles-task'],
  relatedArticles: Ember.computed.alias('task.paper.relatedArticles'),

  actions: {
    newArticle: function() {
      return this.get('store').createRecord(
        'related-article', {
          paper: this.get('task.paper')
        });
    }
  }
});
