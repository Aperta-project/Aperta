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

import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  affiliations: DS.hasMany('affiliation', { async: false }),
  invitations: DS.hasMany('invitation', {
    inverse: 'invitee',
    async: false
  }),

  orcidAccount: DS.belongsTo('orcidAccount'),

  avatarUrl: DS.attr('string'),
  email: DS.attr('string'),
  firstName: DS.attr('string'),
  lastName: DS.attr('string'),
  fullName: DS.attr('string'),
  siteAdmin: DS.attr('boolean'),
  username: DS.attr('string'),

  name: Ember.computed.alias('fullName'),
  affiliationSort: ['isCurrent:desc', 'endDate:desc', 'startDate:asc'],
  affiliationsByDate: Ember.computed.sort('affiliations', 'affiliationSort'),

  invitationsInvited: Ember.computed.filterBy('invitations', 'invited'),
  invitationsNeedsUserUpdate: Ember.computed.filterBy('invitations', 'needsUserUpdate')
});
