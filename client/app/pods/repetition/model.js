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
  cardContent: DS.belongsTo('card-content', { async: false }),
  task: DS.belongsTo('task'),
  answers: DS.hasMany('answer', { async: false }),
  unsortedChildren: DS.hasMany('repetition', { inverse: 'parent', async: false }),
  parent: DS.belongsTo('repetition', { inverse: 'unsortedChildren', async: false }),
  position: DS.attr('number'),

  childrenSort: ['position:asc'],
  children: Ember.computed.sort('unsortedChildren', 'childrenSort'),

  cascadingDestroy() {
    this.get('children').invoke('cascadingDestroy');
    this.get('answers').invoke('destroyRecord');
    this.destroyRecord();
  },
});
