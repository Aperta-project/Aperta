import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import FakeCanService from 'tahi/tests/helpers/fake-can-service';

moduleForComponent('admin-page/email-templates',
  'Integration | Component | Admin Page | Email Templates', {
    integration: true,

    beforeEach() {
      this.can = FakeCanService.create();
      this.register('service:can', this.can.asService());
    }
  }
);

const template = {
  name: 'TPS reports',
  subject: 'Yeaahhhh....'
};

const templates = [template, template];


test('it renders tr in the tbody for each template', function(assert) {
  this.set('templates', templates);
  this.set('journal', {id: 1});

  this.render(hbs`
    {{admin-page/email-templates templates=templates journal=journal}}
  `);

  assert.nElementsFound('.admin-email-template-row', templates.length);
});

test('it does not render a table if there is no journal', function(assert) {
  this.set('templates', templates);
  this.set('journal', null);

  this.render(hbs`
    {{admin-page/email-templates templates=templates journal=journal}}
  `);

  assert.nElementsFound('.admin-email-template-row', 0);
});
