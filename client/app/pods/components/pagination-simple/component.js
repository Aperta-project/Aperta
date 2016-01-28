import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['simple-pagination'],
  page: null,       // pass in
  totalCount: null, // pass in
  perPage: null,    // pass in
  setPage() {},     // pass in as closure action

  init() {
    this._super(...arguments);
    this.set('page', parseInt(this.get('page'))); // params come in as str
  },

  pages: Ember.computed(function(){
    return Math.ceil(this.get('totalCount') / this.get('perPage'))
  }),

  pagesUI: Ember.computed(function(){
    if (this.get('totalCount') == 0) { return '1'; }
    if (!this.get('totalCount')) { return '?'; }
    return this.get('pages');
  }),

  hasPrev: Ember.computed(function(){
    return this.get('page') > 1
  }),

  hasNext: Ember.computed(function(){
    return this.get('page') < this.get('pages')
  }),

  actions: {
    prev() {
      this.setPage(this.get('page') - 1);
    },

    next() {
      this.setPage(this.get('page') + 1);
    }
  }
});
