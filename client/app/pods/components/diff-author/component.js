import Ember from 'ember';

const { computed } = Ember;
const { filterBy, union, sort } = computed;

export default Ember.Component.extend({
  viewing: null, //Snapshots are passed in
  comparing: null,

  isAuthor: Ember.computed('viewing.name', function() {
    return this.get('viewing.name') === 'author';
  }),

  init: function() {
    this._super(...arguments);
    console.log(this.get('viewing'));
  }
});

