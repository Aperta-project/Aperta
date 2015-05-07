import Ember from 'ember';
import DocumentDownload from 'tahi/services/document-download';
import ENV from 'tahi/config/environment';

export default Ember.Mixin.create({
  needs: ['application', 'paper'],
  isAdmin: Ember.computed.alias('currentUser.siteAdmin'),
  canViewManuscriptManager: false,

  supportedDownloadFormats: function() {
    return ENV.APP.iHatExportFormats.map(formatType => {
      return {format: formatType, icon: `svg/${formatType}-icon`};
    });
  }.property(),

  downloadLink: function() {
    return '/papers/' + this.get('model.id') + '/download';
  }.property('model.id'),

  logoUrl: function() {
    let logoUrl = this.get('model.journal.logoUrl');
    return (/default-journal-logo/.test(logoUrl)) ? false : logoUrl;
  }.property('model.journal.logoUrl'),


  // Tasks:
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
  }.property('model.tasks.@each.role'),

  authorTasks: function() {
    var that = this;
    return this.get('model.tasks').filter((task) => {
      return task.get('role') === 'author';
    })
    .filter(function(t) {
      return !(that.get('priorityTasks').contains(t.qualifiedType));
    });
  }.property('model.tasks.@each.role'),

  priorityTasks:       ['TahiStandardTasks::ReviseTask',
                        'PlosBioTechCheck::ChangesForAuthorTask'],
  taskSorting:         ['phase.position', 'position'],
  sortedAuthorTasks:   Ember.computed.sort('authorTasks',   'taskSorting'),
  sortedAssignedTasks: Ember.computed.sort('assignedTasks', 'taskSorting'),
  sortedEditorTasks:   Ember.computed.sort('editorTasks',   'taskSorting'),

  noTasks: function() {
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
