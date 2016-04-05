// Figure snapshot component

import Ember from 'ember';
import namedComputedProperty from 'tahi/mixins/components/snapshot-named-computed-property';

export default Ember.Component.extend({
  snapshot1: null,
  snapshot2: null,
  classNames: ['figure-snapshot'],
  tagName: 'tr',


  file1: namedComputedProperty('snapshot1', 'file'),
  title1: namedComputedProperty('snapshot1', 'title'),

  file2: namedComputedProperty('snapshot2', 'file'),
  title2: namedComputedProperty('snapshot2', 'title')
});
