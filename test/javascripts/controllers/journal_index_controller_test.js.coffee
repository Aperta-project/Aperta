moduleFor 'controller:journalIndex', 'JournalIndexController',
  teardown: -> ETahi.reset()
  setup: ->
    setupApp()

    @paper = Ember.Object.create
      title: 'test paper'

    @paperWithLogo = Ember.Object.create
      title: 'test paper with journal logo'
      logoUrl: 'https://tahi-development.s3-us-west-1.amazonaws.com/uploads/journal/logo/3/thumbnail_Screen%2BShot%2B2014-06-10%2Bat%2B2.59.37%2BPM.png?AWSAccessKeyId=AKIAJHFQZ6WND52M2VDQ&Signature=5w6R%2BYJolrrcs2Dc/ntqRy6/MyQ%3D&Expires=1405980361'

    Ember.run =>
      @controller = @subject()

test '#logo return logoUrl if it exists else return Journal name', ->
  @controller.set('model', @paper)
  equal @controller.get("logo"), undefined
  equal @controller.get("logoUrl"), undefined

test '#logo return logoUrl if it exists else return Journal name', ->
  @controller.set('model', @paperWithLogo)
  ok @controller.get("logo").indexOf('tahi-development.s3') isnt -1
  ok @controller.get("logoUrl").indexOf('tahi-development.s3') isnt -1
