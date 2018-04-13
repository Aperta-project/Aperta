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

/*
  {{#sortable-table content=people as |table|}}
    <tr>
      {{sortable-table-header text="Name"
                              sortProperty="name"
                              sortAscending=table.sortAscending
                              activeSortProperty=table.sortProperty}}
      {{sortable-table-header text="Age"
                              sortProperty="age"
                              sortAscending=table.sortAscending
                              activeSortProperty=table.sortProperty}}
    </tr>
    {{#each table.arrangedContent as |person|}}
      <tr>
        <td>{{person.name}}</td>
        <td>{{person.age}}</td>
      </tr>
    {{/each}}
  {{/sortable-table}}
*/

export default Ember.Component.extend(Ember.SortableMixin, {
  tagName: 'table',
  classNames: ['sortable-table'],

  content: [],
  sortAscending: true,
  sortProperty: null,
  sortProperties: Ember.computed('sortProperty', function() {
    return this.get('sortProperty') ? [this.get('sortProperty')] : [];
  }),

  sortBy(newProperty) {
    if(Ember.isEqual(this.get('sortProperty'), newProperty)) {
      this.toggleProperty('sortAscending');
    } else {
      this.set('sortAscending', true);
      this.set('sortProperty', newProperty);
    }
  }
});
