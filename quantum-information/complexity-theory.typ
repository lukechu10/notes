#import "../template.typ": *

#show: template

#set document(
  title: "Notes on Complexity Theory",
  author: "Luke Chu",
)
#title()

_Last updated: #datetime.today().display()_

These notes are primarily based on the book _Computational Complexity: A Modern Approach_ by Sanjeev Arora and Boaz Barak.

#outline()

= Basic Complexity Classes

== Turing Machines

=== Modelling Computation

The Turing Machine is a useful model of computation that allows us to formally define complexity classes. In particular, any other physically realisable model of computation can be simulated by a Turing Machine with little loss of efficiency (ignoring the possibility of quantum computation, which we will address later in these notes).

We now formally define a Turing Machine.

#definition[Turing Machine][
  A Turing Machine is described by a tuple $(Gamma, Q, delta)$ containing:
  - A finite set $Gamma$ of symbols, called the _tape alphabet_. We assume for simplicity that $Gamma$ contains a special blank symbol $square$, a special start symbol $triangle.r$, and the numbers 0 and 1.
  - A finite set $Q$ of states in which the TM's finite control can be in. We assume that $Q$ contains a special start state $q_"start"$ and a special halting state $q_"halt"$.
  - A transition function $delta: Q times Gamma^k -> Q times Gamma^(k-1) times {L, S, R}^k$, where $k >= 2$ (see @rmk:single-tape-TM).

  The Turing Machine operates as follows. It has $k$ tapes, each of which is infinite towards the right. The first tape is the input tape, which contains the input string $x$ on its leftmost cells and is blank elsewhere. The other tapes are work tapes, which are all initially blank. The TM's finite control is initially in the start state $q_"start"$ and the tape heads are all positioned at the leftmost cell of their respective tapes. At each step, the TM reads the symbols under the tape heads, applies the transition function $delta$ to determine the next state, what symbols to write on each tape, and how to move each tape head (left, stay, right). The TM continues to operate until it reaches the halting state $q_"halt"$, at which point it stops. If the TM tries to go left from the leftmost cell of a tape, it remains in the same position.
]<def:TM>

#remark[
  This is the definition of a multi-tape Turing Machine, where the first tape is the input tape and the other tapes are work tapes. It is also possible to define a single-tape Turing Machine but it is known that multi-tape Turing Machines are equivalent to single-tape Turing Machines up to quadratic slowdown.
]<rmk:single-tape-TM>

#definition[Computing a function and running time][
  Let $f: {0, 1}^* -> {0, 1}^*$ and let $T: NN -> NN$ be some functions, and let $M$ be a TM. We say that $M$ _computes_ $f$ is for every input $x in {0, 1}^*$, $M$ halts with $f(x)$ written on its output tape #footnote[We can adopt the convention that the output tape is the first work tape, and that the input tape is read-only.]. If the number of steps that $M$ takes to halt on input $x$ is at most $T(|x|)$ for every input $x$, we say that $M$ _runs in time_ $T(n)$.
]<def:TM-running-time>

=== Universality

Clearly we can represent TMs by binary strings. We can do this by encoding each element of the TM $(Gamma, Q, delta)$ as a binary string, and then using a binary encoding of a tuple to encode the entire TM. Furthermore, for simplicity, we would like the property that every binary string $x in {0, 1}^*$ represents a valid TM. We can easily achieve this by assigning all invalid binary strings to a trivial TM that immediately halts without doing anything.

With this, we can define a _Universal Turing Machine_ $U$ that takes as input $(M, x)$, where $M$ is understood to be the binary encoding of a TM #footnote[We are using an abuse of notation here by using $M$ to mean both the TM and the binary string representing the TM] and $x$ is an input string. The universal TM then simulates $M$ on input $x$, and halts with the same output as $M$ would have on input $x$.

The existence of an _efficient_ universal Turing Machine is a fundamental result. In particular, we have the following theorem.

#theorem[Efficient Universal Turing Machine][
  There exists a universal Turing Machine $U$ such that for every TM $M$ and input $x$, if $M$ runs in time $T(|x|)$, then $U$ runs in time $c T(|x|)^2$ for some constant $c$ that depends on $M$ but not on $x$.
]<thm:universal-TM>

#proof[Proof sketch][
  The idea is to have $U$ simulate $M$ step by step. We first start by converting $M$ into a single-tape TM $tilde(M)$ (see @rmk:single-tape-TM). This can incur a quadratic slowdown. We can also convert $M$ into a machine with the alphabet ${square, triangle.r, 0, 1}$. From now on, we can assume that $M$ is a single-tape TM with the alphabet ${square, triangle.r, 0, 1}$.

  We then construct the universal TM $U$ as follows. $U$ first decodes its input $(M, x)$ onto the following tapes:
  - The first tape contains the input $x$. This will represent the work tape of $M$ (remember, we are assuming that $M$ is a single-tape TM).
  - The second tape contains the transition function $delta$ of $M$.
  - The third tape contains the current state of $M$. This is initially set to the start state $q_"start"$.

  To simulate one computational step of $M$, $U$ first reads the current state of $M$ from the third tape, and then reads the symbol under the first tape head (which is the work tape of $M$). It then scans through the second tape to find the corresponding transition in $delta$. This takes time proportional to the size of $delta$, which is a constant that depends on $M$ but not on $x$. Once it finds the transition, it updates the first and third tapes accordingly, and moves the first tape head according to the transition. This simulates one step of $M$.
]

#remark[
  @thm:universal-TM can be strengthened to show that there exists a universal TM that runs in time $c T(|x|) log T(|x|)$.
]

== Uncomputability

#theorem[
  There exists a function $f: {0, 1}^* -> {0, 1}^*$ that is not computable by any TM.
]<thm:uncomputable-function>

#proof[
  We can easily construct an explicit example of such a function.

  Let $f$ be defined as follows. For every binary string $x in {0, 1}^*$, let $f(x) = 1$ if the TM represented by $x$ halts on input $x$ and returns 0. Otherwise, let $f(x) = 0$ (i.e. if the TM represented by $x$ does not halt on input $x$, or if it halts and returns something else other than 0).

  Now suppose for contradiction that there exists a TM $M$ that computes $f$. Let $x_M$ be the binary string representing $M$. We have two cases:
  - If $M$ halts on input $x_M$ and returns 0, then by the definition of $f$, we have $f(x_M) = 1$. But since $M$ computes $f$, we also have $f(x_M) = M(x_M) = 0$, which is a contradiction.
  - If $M$ does not halt on input $x_M$, or if it halts and returns something other than 0, then by definition of $f$, we have $f(x_M) = 0$. But since $M$ computes $f$, we also have $f(x_M) = M(x_M) = 1$, which is a contradiction.

  So in either case, we reach a contradiction. Therefore, no TM can compute $f$.
]

#example[
  A more natural example of an uncomputable function is the _halting problem_, which is the function $sans("HALT"): {0, 1}^* -> {0, 1}$ which returns 1 if the TM represented by the input string halts on that input, and returns 0 otherwise.

  If we had a TM $M_"Halt"$ that computes $sans("HALT")$, we could use it to compute the function $f$ defined in the proof of @thm:uncomputable-function, which is a contradiction. The idea is that we can use $M_"Halt"$ to first determine whether some TM $M_x$ halts on input $x$. If it does not halt, we can immediately return 0. If it does halt, we can simulate $M_x$ on input $x$ using the universal TM to determine what it returns.

  Therefore, the halting problem is uncomputable.
]
