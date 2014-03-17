Tahi.overlays['standards/techCheck'] =
  Overlay: React.createClass
    render: ->
      {main, h1, h3, ul, li, label, select, option} = React.DOM

      (main {}, [
        (h1 {}, @props.taskTitle),
        (h3 {}, "Tech check steps"),
        (ul {style: {'list-style-type': 'decimal'}}, [
          (li {}, 'Review ethics statement'),
          (li {}, 'Review competing interest statement'),
          (li {}, 'Review funding disclosure')])])
