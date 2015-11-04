import Ember from 'ember';
import namedComputedProperty from 'tahi/mixins/components/snapshot-named-computed-property';

export default Ember.Component.extend({
  snapshot: null,
  classNames: ["authors-overlay-item--text"],

  firstName: namedComputedProperty('first_name'),
  middleName: namedComputedProperty('middle_initial'),
  lastName: namedComputedProperty('last_name'),
  title: namedComputedProperty('title'),
  department: namedComputedProperty('department'),
  affiliation: namedComputedProperty('affiliation'),
  email: namedComputedProperty('email')
});
