import Ember from 'ember';
import { test, moduleForComponent } from 'ember-qunit';
import startApp from '../helpers/start-app';

moduleForComponent('flow-column', 'Unit: components/flow-column', {
  needs: [
    'component:segmented-button',
    'component:segmented-buttons',
    'component:progress-spinner',
    'component:flow-task-group',
    'component:select-2-single'
  ],

  beforeEach() {
    return startApp();
  }
});

const appendBasicComponent = function(context, attrs) {
  Ember.run(function() {
    context.component = context.subject();
    return context.component.setProperties(attrs);
  });

  return context.render();
};

test('clicking the X should send "removeFlow"', function(assert) {
  const targetObject = {
    externalAction() {
      return assert.ok(true);
    }
  };

  const componentAttrs = {
    removeFlow: 'externalAction',
    targetObject: targetObject,
    flow: Ember.Object.create({
      title: 'Fake Title'
    })
  };

  appendBasicComponent(this, componentAttrs);
  click('.remove-column');
});

test('it forwards viewCard', function(assert) {
  const targetObject = {
    externalAction: function(card) {
      return assert.equal(card, 'test');
    }
  };

  const componentAttrs = {
    viewCard: 'externalAction',
    targetObject: targetObject
  };

  const component = this.subject(componentAttrs);
  component.send('viewCard', 'test');
});
