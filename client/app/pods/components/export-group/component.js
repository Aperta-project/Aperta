import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'table',
  classNames: ['export-history'],
  exportsSort: ['createdAt:desc'],
  sortedExports: Ember.computed.sort('exports', 'exportsSort')
});
