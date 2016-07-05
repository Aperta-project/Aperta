import Ember from 'ember';
import {
  namedComputedProperty
} from 'tahi/mixins/components/snapshot-named-computed-property';

var FigureSnapshot = Ember.Object.extend({
  snapshot: null,
  file: namedComputedProperty('snapshot', 'file'),
  title: namedComputedProperty('snapshot', 'title'),
  strikingImage: namedComputedProperty('snapshot', 'striking_image'),
  fileHash: namedComputedProperty('snapshot', 'file_hash'),
  url: namedComputedProperty('snapshot', 'url')
});

export default Ember.Component.extend({
  snapshot1: null,
  snapshot2: null,
  classNames: ['figure-snapshot'],
  tagName: 'tr',

  figure1: Ember.computed('snapshot1.children.[]', function() {
    return FigureSnapshot.create({snapshot: this.get('snapshot1')});
  }),

  figure2: Ember.computed('snapshot2.children.[]', function() {
    return FigureSnapshot.create({snapshot: this.get('snapshot2')});
  }),

  fileHashChanged: Ember.computed(
    'figure1.fileHash',
    'figure2.fileHash',
    function() {
      var hash1 = this.get('figure1.fileHash');
      var hash2 = this.get('figure2.fileHash');
      if (!hash1 || !hash2) {
          return false;
      } else {
        return hash1 !== hash2;
      }
    }
  )
});
