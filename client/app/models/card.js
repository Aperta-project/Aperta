import DS from 'ember-data';
import Ember from 'ember';

let cardStates = {
  icon: {
    draft: 'fa-pencil-square-o',
    published: 'fa-flag',
    publishedWithChanges: 'fa-pencil-square'
  },
  name: {
    draft: 'draft',
    published: 'published card',
    publishedWithChanges: 'published card with unpublished changes'
  },
  description: {
    draft: `This card is a draft. It can only be viewed by admins at this time. This card cannot
     be added to the workflow until it is published.`,
    publishedWithChanges: `This card has unpublished changes. You can preview both the published card and the
     new unpublished draft of this card in the card preview.`
  }
};

export default DS.Model.extend({
  restless: Ember.inject.service(),
  journal: DS.belongsTo('admin-journal'),
  content: DS.belongsTo('card-content', { async: false }),

  name: DS.attr('string'),
  state: DS.attr('string'),
  addable: DS.attr('boolean'),
  xml: DS.attr('string'),

  stateIcon: Ember.computed('state', function() {
    return cardStates.icon[this.get('state')];
  }),

  publishable: Ember.computed('state', function() {
    let state = this.get('state');
    return state === 'draft' || state === 'publishedWithChanges';
  }),

  stateName: Ember.computed('state', function() {
    return cardStates.name[this.get('state')];
  }),

  stateDescription: Ember.computed('state', function() {
    return cardStates.description[this.get('state')];
  }),

  publish() {
    return this.get('restless').putUpdate(this, `/publish`);
  }
});
