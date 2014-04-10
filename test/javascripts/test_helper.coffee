#= require support/bind-poly
#= require support/sinon
#= require application
#= require support/ember-qunit

# ember-qunit lib setup code
emq.globalize()
ETahi.injectTestHelpers()
setResolver ETahi.__container__
ETahi.setupForTesting()
