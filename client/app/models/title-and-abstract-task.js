import Task from 'tahi/models/task';
import DS from 'ember-data';

export default Task.extend({
  qualifiedType: 'TahiStandardTasks::TitleAndAbstractTask',
  paperTitle: DS.attr('string'),
  paperAbstract: DS.attr('string')
});
