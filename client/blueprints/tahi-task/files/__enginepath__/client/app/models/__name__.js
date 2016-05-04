import Task from 'tahi/models/task';

export default Task.extend({
  qualifiedType: '<%= classifiedEngineName %>::<%= classifiedModuleName %>'
});
