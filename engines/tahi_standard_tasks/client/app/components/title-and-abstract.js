import TaskComponent from 'tahi/pods/components/task-base/component';

export default TaskComponent.extend({
  classNames: ['title-and-abstract'],

  // title would collide with Task.title, so using 'paperTitle' instead
  paperTitle: Ember.computed('task.paper', {
    get(key) {
      return this.get('task.paper.title');
    },
    set(key, value) {
      this.set('task.paper.title', value);
      this.get('task.paper').save();
      return value;
    }
  }),

  // abstract is a keyword, so using 'paperAbstract' instead
  paperAbstract: Ember.computed('task.paper', {
    get(key) {
      return this.get('task.paper.abstract');
    },
    set(key, value) {
      this.set('task.paper.abstract', value);
      this.get('task.paper').save();
      return value;
    }
  }),

  paperNotEditable: Ember.computed.not('task.paper.editable'),
  isNotEditable: Ember.computed.or('task.completed', 'paperNotEditable')
});
