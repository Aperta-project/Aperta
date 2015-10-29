import Ember from 'ember';


export default Ember.Component.extend({
  snapshot: null,
  classNames: ["authors-overlay-item--text"],
  namedProperty(name) {
    let parts = this.get("snapshot.children");
    return _.find(parts, function(part) {
      return part.name === name;
    }).value;
  },

  name: Ember.computed("snapshot.children.[]", function() {
    let parts = this.get("snapshot.children");
    let first = this.namedProperty("first_name");
    let middle = this.namedProperty("middle_initial");
    let last = this.namedProperty("last_name");
    let name = _.compact([first, middle, last]);
    return name.join(" ");
  }),

  title: Ember.computed("snapshot.children.[]", function() {
    return this.namedProperty("title");
  }),

  department: Ember.computed("snapshot.children.[]", function() {
    return this.namedProperty("department");
  }),

  affiliation: Ember.computed("snapshot.children.[]", function() {
    return this.namedProperty("affiliation");
  }),

  email: Ember.computed("snapshot.children.[]", function() {
    return this.namedProperty("email");
  })

});
