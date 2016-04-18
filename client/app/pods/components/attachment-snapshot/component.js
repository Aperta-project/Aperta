import Ember from 'ember';
import {
  namedComputedProperty
} from 'tahi/mixins/components/snapshot-named-computed-property';

export default Ember.Component.extend({
  snapshot: null,
  file: namedComputedProperty('snapshot', 'file'),
  title: namedComputedProperty('snapshot', 'title'),
  caption: namedComputedProperty('snapshot', 'caption')
});
