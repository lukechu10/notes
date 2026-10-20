#import "@preview/theorion:0.6.0": *
#import "@preview/hydra:0.6.3": hydra
#import cosmos.clouds: *

#let template(doc) = [
  #set text(
    font: "New Computer Modern",
    size: 11pt,
  )
  #set par(
    justify: true,
    leading: 0.8em,
    spacing: 1.5em,
  )
  #set heading(numbering: "1.1.1")
  #set page(
    paper: "a4",
    margin: 1in,
    numbering: "1",
    header: context {
      if counter(page).get().first() > 1 {
        [
          _#align(left, hydra(1))_
          #line(length: 100%, stroke: 0.5pt)
        ]
      }
    },
  )

  #show outline.entry.where(level: 1): strong
  #show outline.entry.where(level: 1): set outline.entry(fill: [])

  #show: show-theorion

  // Complexity class configurations
  #show sym.lt.eq: math.scripts

  #set-inherited-levels(1)

  #doc
]
