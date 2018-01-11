import Task from 'tahi/pods/task/model';
import DS from 'ember-data';

export default Task.extend({
  qualifiedType: 'TitleAndAbstractTask',
  paperTitle: DS.attr('string'),
  paperAbstract: DS.attr('string')
});
