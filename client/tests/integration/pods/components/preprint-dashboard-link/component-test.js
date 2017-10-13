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
      let paper = make('paper', {roles: ['Author'], aarxDoi: '1111111'});
      this.set('paper', paper);
    }
  }
);


test('displaying preprint publication', function(assert) {
  this.render(hbs`{{preprint-dashboard-link model=paper type='active'}}`);
  assert.textPresent('.dashboard-manuscript-id', '| ID: 1111111');
  assert.textPresent('.role-tag', 'Author');
});
