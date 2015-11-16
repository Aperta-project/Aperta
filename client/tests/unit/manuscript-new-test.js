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

test('it returns correct title count', function(assert) {
  c.set('paper.title', 'Test');
  assert.equal(c.get('titleCharCount'), 4, 'Char count is correct');
});

test('it returns correct title count with html', function(assert) {
  c.set('paper.title', '<p>Test</p>');
  assert.equal(c.get('titleCharCount'), 4, 'Char count is correct');
});
