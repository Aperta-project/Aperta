`import { formatDate } from 'tahi/helpers/format-date'`

module 'FormatDateHelper'

test 'default formatting', ->
  helper_options = {hash: {}}
  result = formatDate(new Date('2015-02-06 08:00'), helper_options)
  equal(result, 'February 6, 2015', 'returns a human readable date')

test 'specify formatting', ->
  helper_options = {hash: {format: 'l'}}
  result = formatDate(new Date('2015-02-06 08:00'), helper_options)
  equal(result, '2/6/2015', 'returns date in a custom format')
