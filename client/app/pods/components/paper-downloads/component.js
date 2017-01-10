import Component from 'ember-component';
import { task } from 'ember-concurrency';

export default Component.extend({
  classNames: ['sheet', 'sheet--visible'],

  init() {
    this._super(...arguments);
    this.fetchVersions.perform();
  },

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
    }
  }
});
