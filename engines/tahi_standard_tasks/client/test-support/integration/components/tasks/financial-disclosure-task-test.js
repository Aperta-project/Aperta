import Ember from 'ember';
import hbs from 'htmlbars-inline-precompile';
import { test } from 'ember-qunit';
import { make, mockCreate, mockDelete } from 'ember-data-factory-guy';
import moduleForComponentIntegration from 'tahi/tests/helpers/module-for-component-integration';

moduleForComponentIntegration(
  'register-decision-task',
  'Integration | Components | Tasks | Financial Disclosure', {}
);

let template = hbs`{{financial-disclosure-task task=task}}`;


test('Clicking yes creates a new funder', function(assert) {
  Ember.run(() => {
    let card = this.createCard('TahiStandardTasks::FinancialDisclosureTask');
    let task = make('financial-disclosure-task', {card: card});
    this.set('task', task);

    this.fakeCan.allowPermission('edit', task);

    this.createCard('TahiStandardTasks::Funder');
    mockCreate('funder');
    mockCreate('answer');

    this.render(template);
    assert.elementFound(
      "label:contains('Yes')",
      "User can find the 'yes' option'"
    );
    this.$("label:contains('Yes')").click();
    let done = assert.async();
    return this.wait().then(function() {
      assert.mockjaxRequestMade('/api/funders', 'POST', 'creates a new funder');
      assert.mockjaxRequestMade('/api/answers', 'POST', 'creates a new answer');
      assert.elementFound(
        "button:contains('Add Another Funder')",
        'User can add another funder'
      );
      assert.elementFound(
        'span.remove-funder',
        'User can add remove the funder'
      );
      done();
    });
  });
});

test('Existing Funder data is rendered', function(assert) {
  Ember.run(() => {
    let card = this.createCard('TahiStandardTasks::FinancialDisclosureTask');
    let funder = make('funder', {
      name: 'Test Funder',
      grantNumber: 12345,
      website: 'foo.com',
      additionalComments: 'Additional Comments Here'
    });

    let task = make('financial-disclosure-task', {card: card, funders: [funder]});
    this.createAnswer(task, 'financial_disclosures--author_received_funding', {value: true});
    this.set('task', task);

    this.fakeCan.allowPermission('edit', task);

    this.createCard('TahiStandardTasks::Funder');

    this.render(template);
    assert.inputContains(`[name='name']`, 'Test Funder');
    assert.inputContains(`[name='grant_number']`, 12345);
    assert.inputContains(`[name='grant_number']`, 12345);
    assert.inputContains(`[name='website']`, 'foo.com');
    assert.inputContains(`[name='additional_comments']`, 'Additional Comments Here');

    mockDelete('funder', 1);
    this.$('.remove-funder').click();
    let done = assert.async();
    this.wait().then(() => {
      assert.mockjaxRequestMade('/api/funders/1', 'DELETE', 'destroys the funder');
      done();
    });
  });
});
