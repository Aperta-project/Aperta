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

  isHtmlEditor: function() {
    return this.get('model.editorMode') === 'html';
  }.property('model.editorMode'),

  // Tasks:
  assignedTasks: function() {
    let metadataTasks = this.get('metadataTasks');
    var that = this;

    return this.get('model.tasks').filter((task) => {
      return task.get('participations').mapBy('user').contains(that.get('currentUser'));
    }).filter(function(t) {
      return !metadataTasks.contains(t);
    });
  }.property('model.tasks.@each'),

  editorTasks: function() {
    if (this.get('model.editors').contains(this.get('currentUser'))) {
      return this.get('model.tasks').filterBy('role', 'reviewer');
    }
  }.property('model.tasks.@each.role'),

  metadataTasks: function() {
    return this.get('model.tasks').filter((task) => {
      return task.get('is_metadata_task');
    })
  }.property('model.tasks.@each.role'),

  taskSorting:         ['phase.position', 'position'],
  sortedMetadataTasks: Ember.computed.sort('metadataTasks',   'taskSorting'),
  sortedAssignedTasks: Ember.computed.sort('assignedTasks', 'taskSorting'),
  sortedEditorTasks:   Ember.computed.sort('editorTasks',   'taskSorting'),

  noTasks: function() {
    return [this.get('assignedTasks'), this.get('editorTasks'), this.get('metadataTasks')].every((taskGroup)=> {
      return Ember.isEmpty(taskGroup);
    });
  }.property('assignedTasks.@each', 'editorTasks.@each', 'metadataTasks.@each'),


  actions: {
    'export': function(downloadType) {
      return DocumentDownload.initiate(this.get('model.id'), downloadType.format);
    }
  }
});
