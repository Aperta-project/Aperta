import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('admin-page/email-templates',
  'Integration | Component | Admin Page | Email Templates', {
    integration: true
  }
);

const template = {
  text: 'TPS reports',
  subject: 'Yeaahhhh....'
};

test('it renders tr in the tbody for each template', function(assert) {
  const templates = [template, template];
  this.set('templates', templates);

  this.render(hbs`
    {{admin-page/email-templates templates=templates}}
  `);

  assert.nElementsFound('.admin-email-template-row', templates.length);
});
