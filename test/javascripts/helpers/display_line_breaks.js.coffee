module 'helper:displayLineBreaks', 'Unit: Display line breaks',
  setup: -> setupApp()
  teardown: -> ETahi.reset()

test "#displayLineBreaks", ->
  fn = Em.Handlebars.helpers.displayLineBreaks._rawFunction

  equal fn("Tahi\nis\ncool").string, "Tahi<br>is<br>cool"
  equal fn("").string, ""
