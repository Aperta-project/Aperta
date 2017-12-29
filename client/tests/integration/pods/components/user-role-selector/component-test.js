import {
  moduleForComponent,
  test
} from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent(
  'user-role-selector',
  'Integration | Component | user role selector',
  {
    integration: true,
    beforeEach: function() {
      this.set('journalRoles', () => {});
      this.set('userJournalRoles', []);
      this.set('actionStub', []);
    }
  });

var template = hbs`{{user-role-selector
                      journalRoles=journalRoles
                      selected=actionStub
                      removed=actionStub
                      }}`;

test('displays role selector', function(assert) {
  this.render(template);
  assert.elementFound('.user-role-selector', 'role selector is displayed');
});

test('displays assign role button', function(assert) {
  this.render(template);
  assert.elementFound('.assign-role-button', 'assign role button is displayed');
});
