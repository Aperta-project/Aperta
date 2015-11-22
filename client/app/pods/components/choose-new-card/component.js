import Ember from 'ember';
import EscapeListenerMixin from 'tahi/mixins/escape-listener';

const { computed, on } = Ember;

export default Ember.Component.extend(EscapeListenerMixin, {
  phase: null, // passed-in
  journalTaskTypes: null, // passed-in
  isLoading: false, // passed-in

  taskTypeSort: ['title:asc'],
  sortedTaskTypes: computed.sort('journalTaskTypes', 'taskTypeSort'),
  authorTasks: computed.filterBy('sortedTaskTypes', 'role', 'author'),
  staffTasks: computed.setDiff('sortedTaskTypes', 'authorTasks'),

  setuptaskTypeList: on('init', function() {
    if (!this.get('taskTypeList')) {
      this.set('taskTypeList', []);
    }
  }),

  actions: {
    updateList(checkbox) {
      if (checkbox.get('checked')) {
        this.get('taskTypeList').pushObject(checkbox.get('task'));
      } else {
        this.get('taskTypeList').removeObject(checkbox.get('task'));
      }
    },

    addTaskType() {
      this.attrs.addTaskType(
        this.get('phase'),
        this.get('taskTypeList')
      );

      this.attrs.close();
    },

    close() {
      this.attrs.close();
    }
  }
});
