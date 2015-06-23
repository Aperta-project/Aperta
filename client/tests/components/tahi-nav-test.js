import { test, moduleForComponent } from 'ember-qunit';

moduleForComponent('tahi-nav', 'TahiNavComponent');

test('it renders', function(assert) {
  let component = this.subject();

  assert.equal(component._state, 'preRender', 'preRender state');
  this.render();
  assert.equal(component._state, 'inDOM', 'inDOM state');
});
