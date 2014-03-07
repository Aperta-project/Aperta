Tahi.overlays.components.UserThumbnail = React.createClass
  displayName: "UserThumbnail"
  getDefaultProps: ->
    {className: "user-thumbnail", imgSrc: "/images/profile-no-image.jpg", name: "No Name"}
  render: ->
    {div, img} = React.DOM
    {className, imgSrc, name} = @props
    (img {className: className, src: imgSrc, "data-user-name": name, 'data-toggle': 'tooltip', title: name})

  componentDidMount: ->
    $(@getDOMNode()).tooltip placement: 'bottom'
