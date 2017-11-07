import { moduleForComponent, test } from 'ember-qunit';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import { manualSetup, make } from 'ember-data-factory-guy';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent(
  'preprint-dashboard-link',
  'Integration | Component | preprint dashboard link',
  {
    integration: true,
    beforeEach() {
      registerCustomAssertions();
      manualSetup(this.container);
      let attrs = { roles: ['Author'],
        preprintDoiSuffix: '1111111',
        aarxLink: 'http://a-link.co' };
      let paper = make('paper', attrs);
      this.set('paper', paper);
    }
  }
);


test('displaying preprint publication', function(assert) {
  this.render(hbs`{{preprint-dashboard-link model=paper type='active'}}`);
  assert.textPresent('.dashboard-manuscript-id', '| ID: 1111111');
  assert.textPresent('.role-tag', 'Author');
  assert.equal(this.$('a').attr('href'), 'http://a-link.co');
});
