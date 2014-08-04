screenFitScale = () ->
  scaleX = (window.innerWidth / (window.maxX - window.minX)) * .95
  scaleY = (window.innerHeight / (window.maxY - window.minY)) * .95
  Math.min scaleX, scaleY

$ ->
  fitTocenter = () ->
    wx = window.innerWidth / 2
    wy = window.innerHeight / 2

    deltaX = (-window.minX) - (window.maxX - window.minX)/2 + wx
    deltaY = (-window.minY) - (window.maxY - window.minY)/2 + wy

    totalDelta.x += deltaX
    totalDelta.y += deltaY
    
    $('article').animate( { top: "+=#{deltaY}px", left: "+=#{deltaX}px" }, 0, 'linear' )    
    $('.content').css(scale: screenFitScale())

  socket = io.connect()
  fitTocenter()
  scrollTimer = null
  $(window).on 'mousewheel', (event) ->
    event.preventDefault()
    oldScale = $('.content').css 'scale'
    scaleDelta = (parseFloat(oldScale) * (event.deltaY / 100))
    newScale = oldScale - scaleDelta
    if newScale > screenFitScale()/2 && newScale < screenFitScale() * 12
      originX = (event.clientX - $('.content').offset().left) / ($('.content').width() * oldScale)
      originY = (event.clientY - $('.content').offset().top) / ($('.content').height() * oldScale)
      console.log $('.content').css 'transform-origin'
      $('.content').css 'transform-origin': "#{originX * 100}% #{originY * 100}%"
      $('.content').css scale: newScale
      clearTimeout(scrollTimer)
      scrollTimer = setTimeout((() ->
        cluster()
      ), 200)
