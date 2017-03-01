import Ember from 'ember';
import MultiExpandableListMixin from 'tahi/mixins/multi-expandable-list';
import { module, test } from 'qunit';

module('Unit | Mixin | multi expandable list',
       function(hooks) {
         let subject;
         let thing = new Ember.Object({foo: 'bar', id: 1});

         hooks.beforeEach(function () {
           let MultiExpandableListObject = Ember.Object.extend(MultiExpandableListMixin);
           subject = MultiExpandableListObject.create();
         });

         test('it starts out empty', function(assert) {
           assert.ok(Ember.isEmpty(subject.get('expanded')));
         });

         test('it includes an object in expanded if it is toggled once', function(assert) {
           subject.toggleExpanded(thing);
           assert.ok(subject.isExpanded(thing));
         });

         test('it does not include an object in expanded if it is toggled twice', function(assert) {
           subject.toggleExpanded(thing);
           subject.toggleExpanded(thing);
           assert.notOk(subject.isExpanded(thing));
         });

         test('#setExpanded works', function(assert) {
           subject.setExpanded(thing);
           assert.ok(subject.isExpanded(thing));
         });

         test('#setExpanded can be called multiple times with the same effect', function(assert) {
           subject.setExpanded(thing);
           subject.setExpanded(thing);
           assert.ok(subject.isExpanded(thing));
         });


         test('#setUnexpanded works', function(assert) {
           subject.setUnexpanded(thing);
           assert.notOk(subject.isExpanded(thing));
         });

         test('#setUnexpanded can be called multiple times with the same effect', function(assert) {
           subject.setUnexpanded(thing);
           subject.setUnexpanded(thing);
           assert.notOk(subject.get('expanded').contains(thing));
         });
       });
