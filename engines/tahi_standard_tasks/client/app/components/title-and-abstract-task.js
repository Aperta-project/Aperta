import TaskComponent from 'tahi/pods/components/task-base/component';

export default TaskComponent.extend({
  // title would collide with Task.title, so using 'paperTitle' instead
  paperTitle: Ember.computed.alias('task.paper.title'),
  // abstract is a JavaScript reserved word
  paperAbstract: Ember.computed.alias('task.paper.abstract'),
  paperNotEditable: Ember.computed.not('task.paper.editable'),
  isNotEditable: Ember.computed.or('task.completed', 'paperNotEditable'),

  actions: {
    focusOut() {
      return this.get('task.paper').save();
    }
  }
});
