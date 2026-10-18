#import "@preview/theorion:0.6.0": *
#import cosmos.simple: *

#let template(doc) = [
  #set text(
    font: "New Computer Modern",
    size: 11pt,
  )
  #set par(
    justify: true,
    leading: 0.8em,
  )

  #show: show-theorion

  #doc
]
