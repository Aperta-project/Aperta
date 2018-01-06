import Task from 'tahi/pods/task/model';
import DS from 'ember-data';

export default Task.extend({
  currentSettingValue: DS.attr('string')
});
