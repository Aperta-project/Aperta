import Ember from 'ember';
import {
  namedComputedProperty
} from 'tahi/lib/snapshots/snapshot-named-computed-property';

export default Ember.Component.extend({
  viewing: null,
  comparison: null,
  viewingName: namedComputedProperty('viewing', 'name'),
  viewingGrantNumber: namedComputedProperty('viewing', 'grant_number'),
  viewingWebsite: namedComputedProperty('viewing', 'website'),
  viewingInfluence: Ember.computed('viewing.children.[]', function() {
    let children = this.get('viewing.children');
    if (children) return children.findBy('name', 'funder--had_influence');
  }),
  viewingFunderLine: Ember.computed('viewingName', 'viewingWebsite', function() {
    let web = this.get('viewingWebsite'),
      name = this.get('viewingName');
    return web ? `${name} (${web})` : name;
  }),

  comparisonName: namedComputedProperty('comparison', 'name'),
  comparisonGrantNumber: namedComputedProperty('comparison', 'grant_number'),
  comparisonWebsite: namedComputedProperty('comparison', 'website'),
  comparisonInfluence: Ember.computed('comparison.children.[]', function() {
    let children = this.get('comparison.children');
    if (children) return children.findBy('name', 'funder--had_influence');
  }),
  comparisonFunderLine: Ember.computed('comparisonName', 'comparisonWebsite', function() {
    let web = this.get('comparisonWebsite'),
      name = this.get('comparisonName');
    return web ? `${name} (${web})` : name;
  })
});
