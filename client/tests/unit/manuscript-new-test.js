import {
  moduleForComponent,
  test
} from 'ember-qunit';

let c = null;

moduleForComponent('manuscript-new', 'Unit: Manuscript New Component', {
  integration: false,

  beforeEach() {
    c = this.subject();
    c.set('paper', { id: 1 });
  },

  afterEach() {
    c = null;
  }
});
