import Ember from 'ember';
import PaperBase from 'tahi/mixins/controllers/paper-base';
import Discussions from 'tahi/mixins/discussions/route-paths';

export default Ember.Controller.extend(PaperBase, Discussions,  {
  queryParams: ['selectedVersion1', 'selectedVersion2'],
  routing: Ember.inject.service('-routing'),
  paper: Ember.computed.alias('model'),

  taskToDisplay: null,
  showTaskOverlay: false,
  previousURL: null,
  showPdfManuscript: Ember.computed('paper.fileType', 'viewingVersion.fileType',
    function(){
      return this.get('viewingVersion.fileType') ?
        this.get('viewingVersion.fileType') === 'pdf' :
        this.get('paper.fileType') === 'pdf';
    }
  ),
  comparisonIsPdf: Ember.computed.equal('comparisonVersion.fileType', 'pdf'),
  downloadsVisible: false,

  generateTaskVersionURL(task) {
    return this.get('routing.router._routerMicrolib').generate(
      'paper.task.version',
      task.get('paper'),
      task.get('id'),
      {
        queryParams: {
          selectedVersion1: this.get('selectedVersion1'),
          selectedVersion2: this.get('selectedVersion2')
        }
      }
    );
  },

  generatePaperVersionURL(paper) {
    return this.get('routing.router._routerMicrolib').generate(
      'paper.versions',
      paper,
      {
        queryParams: {
          selectedVersion1: this.get('selectedVersion1'),
          selectedVersion2: this.get('selectedVersion2')
        }
      }
    );
  },

  actions: {
    viewCard(task) {
      const r = this.get('routing.router._routerMicrolib');
      const newURL = this.generateTaskVersionURL(task);
      const previousURL = this.generatePaperVersionURL(task.get('paper'));

      r.updateURL(newURL);

      this.setProperties({
        previousURL: previousURL,
        taskToDisplay: task,
        showTaskOverlay: true
      });
    },

    hideTaskOverlay() {
      this.get('routing.router._routerMicrolib')
          .updateURL(this.get('previousURL'));

      this.set('showTaskOverlay', false);
    },

    setViewingVersion(version) {
      this.set('viewingVersion', version);
      this.set(
        'selectedVersion1',
        `${version.get('majorVersion')}.${version.get('minorVersion')}`);
    },

    setComparisonVersion(version) {
      this.set('comparisonVersion', version);
      this.set(
        'selectedVersion2',
        `${version.get('majorVersion')}.${version.get('minorVersion')}`);
    },

    setQueryParam(key, value) {
      this.set(key, value);
    },

    toggleDownloads() {
      this.toggleProperty('downloadsVisible');
    }
  }
});
