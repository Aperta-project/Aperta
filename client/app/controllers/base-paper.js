import Ember from 'ember';
import DocumentDownload from 'tahi/services/document-download';

export default Ember.Controller.extend({
  needs: ['application', 'paper'],
  isAdmin: Ember.computed.alias('currentUser.siteAdmin'),

  canViewManuscriptManager: false,
  supportedDownloadFormats: Ember.computed.alias('controllers.paper.supportedDownloadFormats'),

  downloadLink: function() {
    return '/papers/' + (this.get('model.id')) + '/download';
  }.property('model.id'),

  paper: Ember.computed.alias('model'),

  logoUrl: function() {
    let logoUrl = this.get('model.journal.logoUrl');
    return (/default-journal-logo/.test(logoUrl)) ? false : logoUrl;
  }.property('model.journal.logoUrl'),

  taskSorting: ['phase.position', 'position'],

  authorTasks: Ember.computed.filterBy('model.tasks', 'role', 'author'),

  assignedTasks: function() {
    let authorTasks = this.get('authorTasks');

    return this.get('model.tasks').filter((task) => {
      return task.get('participations').mapBy('user').contains(this.currentUser);
    }).filter(function(t) {
      return !authorTasks.contains(t);
    });
  }.property('model.tasks.@each'),

  editorTasks: function() {
    if (this.get('model.editors').contains(this.get('currentUser'))) {
      return this.get('model.tasks').filterBy('role', 'reviewer');
    }
  }.property('tasks.@each.role'),

  sortedAuthorTasks:   Ember.computed.sort('authorTasks',   'taskSorting'),
  sortedAssignedTasks: Ember.computed.sort('assignedTasks', 'taskSorting'),
  sortedEditorTasks:   Ember.computed.sort('editorTasks',   'taskSorting'),

  sidebarIsEmpty: function() {
    return [this.get('assignedTasks'), this.get('editorTasks'), this.get('authorTasks')].every((taskGroup)=> {
      return Ember.isEmpty(taskGroup);
    });
  }.property('assignedTasks.@each', 'editorTasks.@each', 'authorTasks.@each'),

  actions: {
    'export': function(downloadType) {
      return DocumentDownload.initiate(this.get('model.id'), downloadType.format);
    }
  }
});
