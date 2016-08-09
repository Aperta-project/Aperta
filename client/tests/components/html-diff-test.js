import { test, moduleForComponent } from 'ember-qunit';


moduleForComponent('html-diff', 'Unit: components/html-diff', {
  needs: [],
  beforeEach: function() {
    this.component = this.subject({refreshEquations: false});
  }
});

test("It can diff a single paragraph of a single-sentence", function(assert) {
  this.component.setProperties({
    viewingText: "<p>Hello there</p>",
    comparisonText: "<p>Hi there</p>"
  });

  assert.equal(
    this.component.diff(),
    '<p><span class=\"removed\">Hi there</span>' +
      '<span class=\"added\">Hello there</span></p>'
  );
});

test("It can diff a single paragraph of two sentences", function(assert) {
  this.component.setProperties({
    viewingText: "<p>Hello there. I am a cat.</p>",
    comparisonText: "<p>Hello there. I am a dog.</p>"
  });

  assert.equal(
    this.component.diff(),
    '<p><span class=\"unchanged\">Hello there</span>' +
      '<span class=\"unchanged\">. </span><span class=\"removed\">' +
      'I am a dog</span><span class=\"added\">I am a cat</span>' +
      '<span class=\"unchanged\">.</span><span class=\"unchanged\"></span></p>'
  );
});

test("forceValidHTML adds pairs of elements to `tokens`", function(assert) {
       var tokens =  ["a", "b", "c"];
       this.component.forceValidHTML($("<p>Grandiose</p>")[0], tokens);

       assert.deepEqual(
         tokens,
         [
           "<fake-open-p></fake-open-p>",
           "a", "b", "c",
           "<fake-close-p></fake-close-p>"
         ]
       );
     }
);

test("unForceValidHTML replaces fake- elts with real ones", function(assert) {
  var fakes = "<fake-open-p></fake-open-p>abc<fake-close-p></fake-close-p><fake-open-p></fake-open-p>def<fake-close-p></fake-close-p>";

  assert.equal(
    this.component.unForceValidHTML(fakes),
    "<p>abc</p><p>def</p>"
  );
});

test("unForceValidHTML replaces different fake- elts with real ones", function(assert) {
  var fakes = "<fake-open-p></fake-open-p>abc<fake-close-p></fake-close-p>" +
              "<fake-open-div></fake-open-div>def<fake-close-div></fake-close-div>" +
              "<fake-open-p></fake-open-p>ghi" +
              "<fake-open-div></fake-open-div>jkl<fake-close-div></fake-close-div>" + 
              "<fake-close-p></fake-close-p>";

  assert.equal(
    this.component.unForceValidHTML(fakes),
    "<p>abc</p><div>def</div><p>ghi<div>jkl</div></p>"
  );
});


test("shouldRecurseInto is true if the node is a <p>", function(assert) {
  assert.equal(
    this.component.shouldRecurseInto($("<p>Circumspect</p>")[0]),
    true
  );
});

test("shouldRecurseInto is false if the node is a <figure>", function(assert) {
  assert.equal(
    this.component.shouldRecurseInto($("<figure>Objective</figure>")[0]),
    false
  );
});

test("tokenizeElement breaks sentences into spans", function(assert) {
  var para = $("<p>Elucidate the pingoal. Deviate from supposition.</p>")[0];

  assert.deepEqual(
    this.component.tokenizeElement(para),
    [
      "<fake-open-p></fake-open-p>",
      [
        "<span>Elucidate the pingoal</span>",
        "<span>. </span>",
        "<span>Deviate from supposition</span>",
        "<span>.</span>",
        "<span></span>"
      ],
      "<fake-close-p></fake-close-p>"
    ]
  );
});

test("tokenizeElement leaves figures as atoms", function(assert) {
  var figure = $("<figure>Did you see the day in passing?</figure>")[0];

  assert.equal(
    this.component.tokenizeElement(figure),
    ["<figure>Did you see the day in passing?</figure>"]
  );
});

test("addDiffStylingClass adds class to added chunks", function(assert) {
  assert.equal(
    this.component.addDiffStylingClass({
      value: "<div>Defy the rails on which the world rides.</div>",
      added: true
    }),
    '<div class="added">Defy the rails on which the world rides.</div>'
  );
});

test("addDiffStylingClass adds class to removed chunks", function(assert) {
  assert.equal(
    this.component.addDiffStylingClass({
      value: "<div>We who are about to die would rather not.</div>",
      removed: true
    }),
    '<div class="removed">We who are about to die would rather not.</div>'
  );
});
