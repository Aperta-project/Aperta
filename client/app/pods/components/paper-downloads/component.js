import Ember from 'ember';
import { task } from 'ember-concurrency';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: [
    'paper-downloads-component',
    'sheet',
    'sheet--visible'
  ],

  propTypes: {
    // actions:
    toggle: PropTypes.func.isRequired
  },

  init() {
    this._super(...arguments);
  },

  pdfDownloadLink: Ember.computed('paperid', function() {
    return '/papers/' + this.get('paper.id') + '/download.pdf';
  }),

  versions: [],
  
  modifyVersionString() {
    this.get('versions').forEach(version => {
      version.set('modifiedVersionString', version.get('versionString').replace(/^R\d.\d.+-\s/, ''));
    });
  },

  fetchVersions: task(function * () {
    const versions = yield this.get('paper.versionedTexts');
    this.set('versions', versions);
    this.modifyVersionString();
  }),

  actions: {
    toggle() {
      this.get('toggle')();
    }
  }
});
