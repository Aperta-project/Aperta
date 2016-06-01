import {
  moduleForComponent,
  test
} from 'ember-qunit';
import FactoryGuy from 'ember-data-factory-guy';
import hbs from 'htmlbars-inline-precompile';
import customAssertions from '../helpers/custom-assertions';


moduleForComponent(
  'decision-bar',
  'Integration | Component | decision bar', {
  integration: true,
  beforeEach() {
    customAssertions();
    FactoryGuy.setStore(this.container.lookup('store:main'));
  }
});

test('shows the decision verdict when closed', function(assert) {
  let decision = FactoryGuy.make('decision', { verdict: 'major_revision' });
  setup(this, { decision });
  assert.textPresent(
    '.decision-bar-verdict',
    'Major revision',
    'shows verdict');

  assert.elementNotFound('.decision-bar-letter', 'does not show letter');
});

test('shows the revision number when closed', function(assert) {
  let decision = FactoryGuy.make('decision', {  revisionNumber: 2 });
  setup(this, { decision });
  assert.textPresent('.decision-bar-revision-number', '2', 'shows revision');
});

test('shows the rescinded flag for a rescinded decision when closed',
  function(assert) {
    let decision = FactoryGuy.make('decision', {
      revisionNumber: 2,
      rescindMinorVersion: 3,
      rescinded: true });

    setup(this, { decision });
    assert.textPresent(
      '.decision-bar-revision-number',
      '2.3',
      'shows revision');
    assert.textPresent(
      '.decision-bar-rescinded',
      'Rescinded',
      'shows rescinded flag');
  }
);

test('shows the decision letter when unfolded', function(assert) {
  let decision = FactoryGuy.make('decision', { letter: 'a letter' });
  setup(this, { decision, unfolded: true });
  assert.textPresent('.decision-bar-letter', 'a letter', 'shows letter');
});

test('clicking the verdict unfolds the decision', function(assert) {
  setup(this, {});
  assert.elementNotFound(
    '.decision-bar-letter',
    'is folded (letter invisible)');

  this.$('.decision-bar-bar').click();
  assert.elementFound(
    '.decision-bar-letter',
    'unfolds (letter visible)');
});

test('Author response is present if decision has one', function(assert) {
  let decision = FactoryGuy.make('decision', { authorResponse: 'nuts' });
  setup(this, { decision, unfolded: true });
  assert.textPresent(
    '.decision-bar-author-response',
    'nuts',
    'author response present');
});


function setup(context, {decision, unfolded}) {
  decision = decision || FactoryGuy.make('decision');

  context.set('decision', decision);
  context.set('folded', !unfolded);

  let template = hbs`{{decision-bar decision=decision
                                    folded=folded}}`;

  context.render(template);
}
