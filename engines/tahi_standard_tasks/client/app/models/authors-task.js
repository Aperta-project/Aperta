import DS   from 'ember-data';
import Task from 'tahi/models/task';

export default Task.extend({
  authors: DS.hasMany('author'),
  groupAuthors: DS.hasMany('group-author'),
  qualifiedType: 'TahiStandardTasks::GroupAuthorsTask'
});
