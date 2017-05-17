import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent(
  'card-history/table',
  'Integration | Component | card history | table',
  {
    integration: true
  }
);

let template = hbs`{{card-history/table cardVersions=cardVersions}}`;

test('it renders sorted cardVersions ', function(assert) {
  // Set any properties with this.set('myProperty', 'value');
  // Handle any actions with this.on('myAction', function(val) { ... });
  this.set('cardVersions', [
    {
      publishedAt: moment().subtract(20, 'days').toDate(),
      historyEntry: 'Oldest',
      isPublished: true
    },
    {
      publishedAt: moment().toDate(),
      historyEntry: 'Newer',
      isPublished: true
    },
    { publishedAt: null, historyEntry: 'Newest', isPublished: false }
  ]);

  this.render(template);

  assert.arrayContainsExactly(
    this.$('.history-entry').map((i, e) => e.innerText).get(),
    ['Newest', 'Newer', 'Oldest']
  );
});

test('rendering for an individual version', function(assert) {
  // Set any properties with this.set('myProperty', 'value');
  // Handle any actions with this.on('myAction', function(val) { ... });
  this.set('cardVersions', [
    {
      publishedAt: moment().subtract(20, 'days').toDate(),
      historyEntry: 'Oldest',
      publishedBy: 'Steve'
    }
  ]);

  this.render(template);
  assert.textPresent(
    '.history-entry',
    'Oldest',
    'displays the given history entry'
  );
  assert.textPresent('.published-by', 'Steve', 'displays publishedBy if given');

  this.set('cardVersions', [
    {
      publishedAt: null,
      publishedBy: null,
      historyEntry: null
    }
  ]);
  assert.textPresent(
    '.history-entry',
    'Current Unpublished Version',
    'displays placeholder for the latest version'
  );
});
