import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';

export default TaskComponent.extend({
  dataLocationQuestion: Ember.computed('task', function(){
    return this.get('task')
               .findQuestion('data_availability--data_location');
  }),

  fullyAvailableQuestion: Ember.computed('task', function(){
    return this.get('task')
               .findQuestion('data_availability--data_fully_available');
  }),
});
