import Ember from 'ember';
import namedComputedProperty from 'tahi/mixins/components/snapshot-named-computed-property';

export default Ember.Component.extend({
  snapshot: null,
  name: namedComputedProperty('name'),
  grantNumber: namedComputedProperty('grant_number'),
  website: namedComputedProperty('website'),
  influence: namedComputedProperty('funder_had_influence')
});
