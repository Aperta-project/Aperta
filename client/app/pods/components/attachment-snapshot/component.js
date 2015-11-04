import Ember from 'ember';
import namedComputedProperty from 'tahi/mixins/components/snapshot-named-computed-property';

export default Ember.Component.extend({
  snapshot: null,
  url: namedComputedProperty('file'),
  title: namedComputedProperty('title'),
  caption: namedComputedProperty('caption')
});
