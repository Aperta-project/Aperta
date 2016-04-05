import Ember from 'ember';
import namedComputedProperty from 'tahi/mixins/components/snapshot-named-computed-property';

export default Ember.Component.extend({
  snapshot: null,
  name: namedComputedProperty('snapshot', 'name'),
  grantNumber: namedComputedProperty('snapshot', 'grant_number'),
  website: namedComputedProperty('snapshot', 'website'),
  influence: namedComputedProperty('snapshot', 'funder_had_influence')
});
