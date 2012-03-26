###
impress.coffee

impress.coffee is rewrite of the javascript based presentation tool impress.js
by Bartek Szopka (@bartaz).

The main purpoise of this rewrite is not to replace impress.js but to teach me
some coffee script. The goal is to make a completely compatible version of
impress.js in coffeescript.

MIT Licensed.

Copyright 2012 Moritz Grauel (@mo_gr)
###

###
helper functions
###
styleDummy = document.createElement('dummy').style
prefixes = ["Webkit", "Moz", "O", "ms", "Khtml"]
prefixMemory = {}

# find the supported prefix of a property and return it
pfx = (prop) ->
  if (! prefixMemory[prop]?)
    uppercaseProp = prop[0].toUpperCase() + prop.substr(1)
    props = (prop + " " + prefixes.join(uppercaseProp + " ") + uppercaseProp).split(" ")
    prefixMemory[prop] = null
    for property in props
      if styleDummy[property]?
        prefixMemory[prop] = property
        break
  prefixMemory[prop]

byId = (id) ->
  document.getElementById id

getElementFromUrl = () ->
  byId window.location.hash.replace(/^#\/?/, "")

toArray = (a) ->
  Array.prototype.slice.call(a)

$$ = ( selector, context = document ) ->
  toArray context.querySelectorAll(selector)

css = ( el, props ) ->
  for styleKey, value of props
    el.style[pfx(styleKey)] = value
  el

###
CSS Helper
###
translate =  ( t ) ->
  " translate3d(" + t.x + "px," + t.y + "px," + t.z + "px) "

rotate = ( r, revert ) ->
  rX = " rotateX(" + r.x + "deg) "
  rY = " rotateY(" + r.y + "deg) "
  rZ = " rotateZ(" + r.z + "deg) "
  if revert then rZ+rY+rX else rX+rY+rZ

scale = ( s ) ->
  " scale(" + s + ") "

###
check support
###
ua = navigator.userAgent.toLowerCase()

impressSupported = pfx("perspective")? and ua.search(/(iphone)|(ipod)|(ipad)|(android)/) == -1

###
DOM Elements
###

impress = byId "impress"

impress.className = if impressSupported then "" else "impress-not-supported"

canvas = document.createElement "div"
canvas.className = "canvas"

toArray(impress.childNodes).forEach(
  (slide) -> canvas.appendChild slide
)

impress.appendChild canvas

#steps = $$(".step", impress)
steps = $$("article", impress)

###
Setup the document
###
document.documentElement.style.height = "100%"

css document.body, {
  height: "100%",
  overflow: "hidden"
}

props = {
  position: "absolute",
  transformOrigin: "top left",
  transition: "all 0s ease-in-out",
  transformStyle: "preserve-3d"
}

css impress, props
css impress, {
  top: "50%",
  left: "50%",
  perspective: "1000px"
}
css canvas, props

current = {
  translate: { x: 0, y: 0, z: 0 },
  rotate:    { x: 0, y: 0, z: 0 },
  scale:     1
}

###
position the slides on the canvas
###

for step, idx in steps
  data = step.dataset
  stepData = {
    translate: {
      x: data.x || 0,
      y: data.y || 0,
      z: data.z || 0
    },
    rotate: {
      x: data.rotateX || 0,
      y: data.rotateY || 0,
      z: data.rotateZ || data.rotate || 0
    },
    scale: data.scale || 1
  }
  step.stepData = stepData;
  step.id = "step-" + idx unless step.id

  css step, {
    position: "absolute",
    transform: "translate(-50%,-50%)" +
      translate(stepData.translate) +
      rotate(stepData.rotate) +
      scale(stepData.scale),
    transformStyle: "preserve-3d"
  }

###
make a given step active
###

active = null;
hashTimeout = null;

select = (el) ->
  return false unless el and el.stepData and el != active

  window.scrollTo 0, 0
  step = el.stepData

  active.classList.remove "active" if active?
  el.classList.add "active"

  impress.className = "step-" + el.id

  window.clearTimeout hashTimeout
  hashTimeout = window.setTimeout( () ->
    window.location.hash = "#/" + el.id
  , 1000)

  target = {
    rotate: {
      x: -parseInt(step.rotate.x, 10),
      y: -parseInt(step.rotate.y, 10),
      z: -parseInt(step.rotate.z, 10)
    },
    translate: {
      x: -step.translate.x,
      y: -step.translate.y,
      z: -step.translate.z
    },
    scale: 1 / parseFloat(step.scale)
  }

  zooming = target.scale >= current.scale

  duration = if active then "1s" else "0"

  css impress, {
    perspective: step.scale * 1000 + "px",
    transform: scale(target.scale),
    transitionDuration: duration,
    transitionDelay: if zooming then "500ms" else "0ms"
  }

  css canvas, {
    transform: rotate(target.rotate, true) + translate(target.translate),
    transitionDuration: duration,
    transitionDelay: if zooming then "0ms" else "500ms"
  }

  current = target
  active = el

selectPrev = () ->
  prev = steps.indexOf( active ) - 1
  prev = if prev >= 0 then steps[prev] else steps[steps.length - 1]
  select prev

selectNext = () ->
  next = steps.indexOf(active) + 1
  next = if next < steps.length then steps[next] else steps[0]
  select next

###
Event Listener
###
document.addEventListener("keydown", (event) ->
  if event.target.tagName == "PRE"
    return
  if event.keyCode in [33, 37, 38]
    selectPrev()
    event.preventDefault()
  if event.keyCode in [9, 32, 34, 39, 40]
    selectNext()
    event.preventDefault()
, false)

document.addEventListener("click", (event) ->
  target = event.target
  while (target.tagName != "A" and not target.stepData and target != document.body)
    target = target.parentNode

  if target.tagName == "A"
    href = target.getAttribute "href"
    target = byId href.slice(1) if href and href[0] == '#'

  if select target
    event.preventDefault()
, false)

window.addEventListener("hashchange", () ->
  select getElementFromUrl()
, false)

document.selectNextSlide = selectNext
document.selectPrevSlide = selectPrev

###
start impress
###

select getElementFromUrl() || steps[0]
