import Task from 'tahi/models/task';

export default Task.extend({
  qualifiedType: 'TahiStandardTasks::TitleAndAbstractTask',
  paperTitle: DS.attr('string'),
  paperAbstract: DS.attr('string')
});
