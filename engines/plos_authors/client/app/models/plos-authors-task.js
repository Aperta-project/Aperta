import DS   from 'ember-data';
import Task from 'tahi/models/task';

export default Task.extend({
  plosAuthors: DS.hasMany('plosAuthor'),
  qualifiedType: 'TahiStandardTasks::PlosAuthorsTask',
  isMetadataTask: true
});
