`import { test } from 'ember-qunit'`
`import DisplayLineBreaks from '../../helpers/display-line-breaks'`

module 'helper:display-line-breaks', 'Unit: Display line breaks'

test "#displayLineBreaks", ->
  equal DisplayLineBreaks._rawFunction("Tahi\nis\ncool").string, "Tahi<br>is<br>cool"
  equal DisplayLineBreaks._rawFunction("").string, ""
