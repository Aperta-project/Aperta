import DS from 'ember-data';
import Ember from 'ember';

export default DS.Model.extend({
  restless: Ember.inject.service(),
  journal: DS.belongsTo('admin-journal'),
  content: DS.belongsTo('card-content', { async: false }),

  name: DS.attr('string'),
  state: DS.attr('string'),
  xml: DS.attr('string'),

  stateIcon: Ember.computed('state', function() {
    return {
      draft: 'fa-pencil-square-o',
      published: 'fa-flag',
      publishedWithChanges: 'fa-pencil-square'
    }[this.get('state')];
  }),

  stateName: Ember.computed('state', function() {
    return {
      draft: 'draft',
      published: 'published card',
      publishedWithChanges: 'published card with unpublished changes'
    }[this.get('state')];
  }),

  publish() {
    return this.get('restless')
      .putUpdate(this, `/publish`);
  }
});
