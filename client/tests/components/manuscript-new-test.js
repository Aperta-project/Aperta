import {
  moduleForComponent,
  test
} from 'ember-qunit';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent('overlays/manuscript-new', 'ManuscriptNewComponent', {
  integration: true,

  beforeEach() {
    this.setProperties({
      newPaper: {
        id: 1,
        title: '',
      },
      journals: []
    });
  }
});

test('it renders', function(assert) {
  assert.expect(1);

  this.render(hbs`
    {{overlays/manuscript-new}}
  `);

  assert.equal(this.$('.select-box').length, 1);
});
