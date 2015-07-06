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
