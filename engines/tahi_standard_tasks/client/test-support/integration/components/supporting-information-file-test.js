import { moduleForComponent, test } from 'ember-qunit';
import { manualSetup, make } from 'ember-data-factory-guy';
import { initialize as initTruthHelpers }  from 'tahi/initializers/truth-helpers';
import customAssertions from '../helpers/custom-assertions';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';


moduleForComponent(
  'supporting-information-file',
  'Integration | Component | supporting information file',
  {
    integration: true,
    beforeEach() {
      initTruthHelpers();
      customAssertions();
      manualSetup(this.container);
    }
  });


test('user can edit an existing file and then cancel', function() {

  this.set('fileProxy', Ember.Object.create({
    object: make('supporting-information-file')
  }));

  let template = hbs`{{supporting-information-file isEditable=true, model=fileProxy}}`;

  this.render(template);
});
