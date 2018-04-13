/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

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
    publishedWithChanges: `This card has unpublished changes. The card preview
     shows the unpublished draft of this card.`
  }
};

export default DS.Model.extend({
  restless: Ember.inject.service(),
  journal: DS.belongsTo('admin-journal'),
  content: DS.belongsTo('card-content', { async: false }),
  cardVersions: DS.hasMany('card-version'),
  cardTaskType: DS.belongsTo('card-task-type'),

  name: DS.attr('string'),
  state: DS.attr('string'),
  addable: DS.attr('boolean'),
  workflow_only: DS.attr('boolean'),
  xml: DS.attr('string'),
  title: Ember.computed.alias('name'),
  // used by the publish() function, set in the card editor's publish modal
  historyEntry: '',

  stateIcon: Ember.computed('state', function() {
    return cardStates.icon[this.get('state')];
  }),

  publishable: Ember.computed('state', function() {
    let state = this.get('state');
    return state === 'draft' || state === 'publishedWithChanges';
  }),

  revertable: Ember.computed.equal('state', 'publishedWithChanges'),

  stateName: Ember.computed('state', function() {
    return cardStates.name[this.get('state')];
  }),

  stateDescription: Ember.computed('state', function() {
    return cardStates.description[this.get('state')];
  }),

  publish() {
    let historyEntry = this.get('historyEntry');
    return this.get('restless')
      .putUpdate(this, `/publish`, { historyEntry })
      .finally(() => {
        this.set('historyEntry', '');
      });
  },

  revert() {
    return this.get('restless').putUpdate(this, `/revert`);
  },

  archive() {
    return this.get('restless').putUpdate(this, `/archive`);
  }
});
