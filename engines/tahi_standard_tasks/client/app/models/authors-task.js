import DS   from 'ember-data';
import Task from 'tahi/models/task';

export default Task.extend({
  authors: DS.hasMany('author'),
  groupAuthors: DS.hasMany('group-author'),
  qualifiedType: 'TahiStandardTasks::GroupAuthorsTask',

  allAuthorsUnsorted: Ember.computed.union('authors', 'groupAuthors'),
  allAuthorsSortingAsc: ['position:asc'],
  allAuthors: Ember.computed.sort('allAuthorsUnsorted', 'allAuthorsSortingAsc'),
});
