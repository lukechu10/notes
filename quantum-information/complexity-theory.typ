#import "../template.typ": *

#show: template

= Complexity Theory

_Last updated: #datetime.today().display()_

These notes are primarily based on the book _Computational Complexity: A Modern Approach_ by Sanjeev Arora and Boaz Barak.

== Basic Complexity Classes

=== Turing Machines

The Turing Machine is a useful model of computation that allows us to formally define complexity classes. In particular, any other physically realisable model of computation can be simulated by a Turing Machine with little loss of efficiency (ignoring the possibility of quantum computation, which we will address later in these notes).

The Turing Machine can be formally defined as follows.

#definition[Turing Machine][
  A Turing Machine is described by a tuple $(Gamma, Q, delta)$ containing:
  - A finite set $Gamma$ of symbols, called the _tape alphabet_. We assume for simplicity that $Gamma$ contains a special blank symbol $square$, a special start symbol $triangle.r$, and the numbers 0 and 1.
  - A finite set $Q$ of states in which the TM's finite control can be in. We assume that $Q$ contains a special start state $q_"start"$ and a special halting state $q_"halt"$.
  - A transition function $delta: Q times Gamma^k -> Q times Gamma^(k-1) times {L, S, R}^k$, where $k >= 2$ (see @rmk:single-tape-TM).
]<def:TM>

#remark[
  This is the definition of a multi-tape Turing Machine, where the first tape is the input tape and the other tapes are work tapes. It is also possible to define a single-tape Turing Machine but it is known that multi-tape Turing Machines are equivalent to single-tape Turing Machines up to polynomial time overhead.
]<rmk:single-tape-TM>
