import Task from 'tahi/models/task';
import DS from 'ember-data';

export default Task.extend({
  currentSettingValue: DS.attr('string')
});
