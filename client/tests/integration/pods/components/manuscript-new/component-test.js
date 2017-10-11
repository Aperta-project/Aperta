import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import { make, manualSetup }  from 'ember-data-factory-guy';
import Ember from 'ember';
import { clickTrigger } from 'tahi/tests/helpers/ember-power-select';

moduleForComponent('manuscript-new', 'Integration | Component | manuscript new', {
  integration: true,

  beforeEach: function () {
    manualSetup(this.container);
  }
});

test('it renders article types in the correct order', function(assert) {
  const paperTypeNames = ['Pickachu', 'Research Article', 'Bulbasaur', 'Methods and Resources'];
  const expectedOrder = ['Research Article', 'Methods and Resources', 'Bulbasaur', 'Pickachu'];
  const manuscriptManagerTemplates = Ember.A($.map(paperTypeNames, (n) => {
    return {paper_type: n};
  }));
  this.paper = make('paper', { journal: { manuscriptManagerTemplates }});
  this.render(hbs`{{manuscript-new paper=paper}}`);
  clickTrigger('#paper-new-paper-type-select');
  const options = $('.ember-power-select-option');
  const values = $.map(options, (o) => { return o.textContent.trim(); });
  assert.deepEqual(values, expectedOrder);
});
