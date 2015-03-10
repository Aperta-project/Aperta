`import { formatDate } from 'tahi/helpers/format-date'`

module 'FormatDateHelper'

test 'default formatting', ->
  helper_options = {hash: {}}
  result = formatDate(new Date('February 06, 1990'), helper_options)
  equal(result, 'February 6, 1990', 'returns a human readable date')

test 'specify formatting', ->
  helper_options = {hash: {format: 'l'}}
  result = formatDate(new Date('February 06, 1990'), helper_options)
  equal(result, '2/6/1990', 'returns date in a custom format')
