import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import { make, manualSetup } from 'ember-data-factory-guy';
import moment from 'moment';

moduleForComponent('invitation-header', 'Integration | Component | invitation header', {
  integration: true,

  beforeEach: function () {
    manualSetup(this.container);
  },

  setupAndRender(invitationOptions) {
    this.set('invitation', make('invitation', invitationOptions));
    this.render(hbs`{{invitation-header invitation=invitation}}`);
  }
});

test('it displays the invitation role', function(assert) {
  const inviteeRole = 'Pokémon Professor';
  this.setupAndRender({inviteeRole});
  assert.textPresent('.invitation-type', inviteeRole);
});

test("it displays the invitation's paper's title", function(assert) {
  const title = 'Bulbasaur Stuff';
  this.setupAndRender({title});
  assert.textPresent('.invitation-paper-title', title);
});

test("it displays the invitation's paper's title", function(assert) {
  const paperType = 'Pokémon Research Article';
  this.setupAndRender({paperType});
  assert.textPresent('.invitation-paper-type',paperType);
});

test("it displays the invitation's send date", function(assert) {
  const createdAt = moment('1997-08-29');
  this.setupAndRender({createdAt});
  assert.textPresent('.date', 'August 29, 1997');
});
