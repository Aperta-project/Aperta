import Ember from 'ember';
import PaperBase from 'tahi/mixins/controllers/paper-base';
import Discussions from 'tahi/mixins/discussions/route-paths';

export default Ember.Controller.extend(PaperBase, Discussions,  {
  routing: Ember.inject.service('-routing'),
  queryParams: ['majorVersion', 'minorVersion'],

  taskToDisplay: null,
  showTaskOverlay: false,
  previousURL: null,

  generateTaskVersionURL(task) {
    return this.get('routing.router.router').generate(
      'paper.task.version',
      task.get('paper'),
      task.get('id'),
      {
        queryParams: {
          majorVersion: this.get('majorVersion'),
          minorVersion: this.get('minorVersion')
        }
      }
    );
  },

  generatePaperVersionURL(paper) {
    return this.get('routing.router.router').generate(
      'paper.versions',
      paper,
      {
        queryParams: {
          majorVersion: this.get('majorVersion'),
          minorVersion: this.get('minorVersion')
        }
      }
    );
  },

  actions: {
    viewCard(task) {
      const r = this.get('routing.router.router');
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
      this.get('routing.router.router')
          .updateURL(this.get('previousURL'));

      this.set('showTaskOverlay', false);
    },

    setViewingVersion(version) {
      this.set('viewingVersion', version);
      this.set('majorVersion', version.get('majorVersion'));
      this.set('minorVersion', version.get('minorVersion'));
    },

    setComparisonVersion(version) {
      this.set('comparisonVersion', version);
    }
  }
});
