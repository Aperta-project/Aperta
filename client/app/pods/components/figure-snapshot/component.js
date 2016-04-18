// Figure snapshot component

import Ember from 'ember';
import {
  namedComputedProperty
} from 'tahi/mixins/components/snapshot-named-computed-property';

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
      return this.get('figure1.fileHash') !== this.get('figure2.fileHash');
    }
  )
});

var FigureSnapshot = Ember.Object.extend({
  snapshot: null,
  file: namedComputedProperty('snapshot', 'file'),
  title: namedComputedProperty('snapshot', 'title'),
  strikingImage: namedComputedProperty('snapshot', 'striking_image'),
  fileHash: namedComputedProperty('snapshot', 'file_hash')
});
