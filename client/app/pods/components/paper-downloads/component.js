import Ember from 'ember';
import { task } from 'ember-concurrency';

export default Ember.Component.extend({
  classNames: ['sheet', 'sheet--visible'],

  init() {
    this._super(...arguments);
    this.fetchVersions.perform();
  },

  pdfDownloadLink: Ember.computed('paperid', function() {
    return '/papers/' + this.get('paper.id') + '/download.pdf';
  }),

  versions: [],
  fetchVersions: task(function * () {
    const promise = this.get('paper.versionedTexts');
    yield promise;
    promise.then((versions)=> {
      this.set('versions', versions);
    });
  }),

  actions: {
    toggle() {
      this.get('toggle')();
    },

    exportDocument(version) {
      this.get('exportDocument')(
        version.get('fileType'),
        version.get('id')
      );
    }
  }
});
