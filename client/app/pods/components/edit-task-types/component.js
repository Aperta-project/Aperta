import Ember from 'ember';
import EscapeListenerMixin from 'tahi/mixins/escape-listener';

export default Ember.Component.extend(EscapeListenerMixin, {
  taskTypeSort: ['title:asc'],
  sortedTaskTypes: Ember.computed.sort(
    'model.journalTaskTypes', 'taskTypeSort'
  ),

  actions: {
    close() {
      this.attrs.close();
    }
  }
});
