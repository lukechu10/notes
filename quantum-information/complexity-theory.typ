#import "../template.typ": *
#import "../complexity-classes.typ" as class

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

#example[The halting problem][
  A more natural example of an uncomputable function is the _halting problem_, which is the function $sans("HALT"): {0, 1}^* -> {0, 1}$ which returns 1 if the TM represented by the input string halts on that input, and returns 0 otherwise.

  If we had a TM $M_"Halt"$ that computes $sans("HALT")$, we could use it to compute the function $f$ defined in the proof of @thm:uncomputable-function, which is a contradiction. The idea is that we can use $M_"Halt"$ to first determine whether some TM $M_x$ halts on input $x$. If it does not halt, we can immediately return 0. If it does halt, we can simulate $M_x$ on input $x$ using the universal TM to determine what it returns.

  Therefore, the halting problem is uncomputable.
]

== The complexity class $class.P$

A common framework for studying the (time) complexity of problems is in terms of _languages_ and _decision problems_. A language $L$ is a subset of ${0, 1}^*$ and a decision problem is a problem that can be phrased as a question of whether a given string $x in {0, 1}^*$ belongs to some language $L$. Informally, we can think of decision problems as yes/no questions about strings.

We say that a TM $M$ _decides_ a language $L$ if $M$ computes $f_L: {0, 1}^* -> {0, 1}$ where $f(x) = 1 <=> x in L$. $f_L$ is also called the _characteristic function_ of $L$.

#definition[The class $sans("DTIME")$][
  Let $T: NN -> NN$ be a function. We define the complexity class $class.DTIME(T(n))$ as the set of languages $L$ such that there exists a TM $M$ that decides $L$ and runs in time $c T(n)$ for some positive constant $c$.
]<def:DTIME>

The D in the name $sans("DTIME")$ stands for "deterministic" since we are considering deterministic Turing Machines. We can also define the class $class.NTIME(T(n))$ in a similar way, but using non-deterministic Turing Machines instead.

Now we can try to define what we mean by "efficiently solvable" problems. A common definition is that a problem is efficiently solvable if it can be solved in polynomial time. This leads us to the following definition.

#definition[The class $class.P$][
  $class.P = union_(c in NN) class.DTIME(n^c)$.
]<def:P>

We say that some decision problems has an efficient algorithm if it is in $class.P$.

#remark[
  The definition of $class.P$ seems to depend on the choice of the model of computation (e.g. Turing Machines, RAM machines, etc.). However as we claimed earlier, any physically realisable model of computation can be simulated by a Turing Machine with at most a polynomial slowdown. Therefore, the definition of $class.P$ is robust to the choice of model of computation.
]

== The complexity class $class.NP$

Informally, the class $class.NP$ represents problems whose solutions can be _verified_ in polynomial time.

#definition[The class $class.NP$][
  A language $L$ is in $class.NP$ if there exists a polynomial $p(n)$ and a polynomial-time TM $M$ such that $forall x in {0, 1}^*$, $x in L$ iff $exists u in {0, 1}^p(|x|)$ such that $M(x, u) = 1$. If there exists a string $u$ such that $M(x, u) = 1$, then $u$ is called a _certificate_ of $x$. $M$ is called the _verifier_ of $L$.
]<def:NP>

#remark[
  The definition of $class.NP$ can be equivalently phrased in terms of non-deterministic Turing Machines. In particular, we can start by defining the class $class.NTIME(T(n))$ like we did for $class.DTIME(T(n))$, but using non-deterministic Turing Machines instead. Then we can define $class.NP = union_(c in NN) class.NTIME(n^c)$.
]

#remark[
  Clearly we have $class.P subset.eq class.NP$ since the certificate $u$ can be the empty string. However, it is an open question whether $class.P = class.NP$ or if $class.P$ is a strict subset of $class.NP$.
]

#example[
  TODO: Give some examples of problems in $class.NP$.
]

=== $class.NP$-completeness

Some problems in $class.NP$ have the fascinating property that if there were an efficient algorithm for them, then there would be an efficient algorithm for _every_ problem in $class.NP$. These problems can be thought of as the "hardest" problems in $class.NP$ and are called $class.NPhard$.

If furthermore this problem is also in $class.NP$, then it is called $class.NPcomplete$. In other words, $class.NPcomplete = class.NP inter class.NPhard$.

To make this more precise, we need to define what it means for one problem to be "at least as hard" as another problem. We do this using the notion of polynomial-time reductions.

#definition[Polynomial-time reductions, $class.NP$-hardness][
  Let $L_1, L_2 subset.eq {0, 1}^*$ be two languages. We say that $L_1$ is _polynomial-time reducible_ to $L_2$, denoted $L_1 <=_p L_2$, if there exists a polynomial-time computable function $f: {0, 1}^* -> {0, 1}^*$ such that for every $x in {0, 1}^*$, $x in L_1$ iff $f(x) in L_2$. The function $f$ is called a _reduction_ from $L_1$ to $L_2$.

  We say that $L in class.NPhard$ if $forall L' in class.NP, L' <=_p L$.
]<def:poly-reduction>

#lemma[
  If $L_1 <=_p L_2$ and $L_2 in class.P$, then $L_1 in class.P$. In other words, $class.P$ is closed under polynomial-time reductions.
]

#proof[
  We can construct a polynomial-time algorithm for $L_1$ as follows. Given an input $x$, we first compute $f(x)$ in polynomial time, and then run the polynomial-time algorithm for $L_2$ on input $f(x)$. The input to the algorithm for $L_2$ has size at most polynomial in the size of $x$, so the overall running time is polynomial in the size of $x$. Therefore, $L_1 in class.P$.
]

Similarly, we can easily show that if $L_1 <=_p L_2$ and $L_2 in class.NP$, then $L_1 in class.NP$. In other words, $class.NP$ is also closed under polynomial-time reductions.

#remark[
  We cannot use polynomial-time reductions to classify problems _within_ $class.P$, such as for defining a notion of $class.P$-completeness. This is because polynomial-time reductions have the same power as the class $class.P$ itself. In particular, if we define $class.P$-hardness using polynomial-time reductions, then almost every problem in $class.P$ would be $class.P$-hard, since we can solve the problem outright in the reduction itself.

  To create a theory about the internal structure of $class.P$, we need to use a more restrictive notion of reductions, such as log-space reductions.
]

#example[
  Some examples of $class.NPcomplete$ problems include:
  - The Boolean satisfiability problem (SAT): given a boolean formula, determine if there exists an assignment of truth values to the variables that make the formula evaluate to true (@thm:Cook-Levin).
  - The Hamiltonian cycle problem: given a graph, determine if there exists a cycle that visits every vertex exactly once.
  - The clique problem: given a graph and an integer $k$, determine if there exists a complete subgraph (clique) of size $k$.
]

#theorem[Cook-Levin theorem][
  The Boolean satisfiability problem (SAT) is $class.NPcomplete$.
]<thm:Cook-Levin>

#proof[
  TODO
]

#emph-block[
  *Summary*:
  - The notion of _computability_ is formalised using Turing Machines. Not all functions are computable, and the halting problem is a canonical example of an uncomputable function.
  - We often work in the framework of _decision problems_ and _languages_. These decision problems can be classified into _complexity classes_, based on the resources required to solve them. The most fundamental complexity classes are $class.P$ and $class.NP$ which represent problems that can be solved in polynomial time and problems whose solutions can be verified in polynomial time, respectively. The question of whether $class.P = class.NP$ is one of the most important open questions in computer science.
  - Some problems in $class.NP$ are $class.NPhard$, meaning that they are the "hardest" problems in $class.NP$. If any $class.NPhard$ problem can be solved in polynomial time, then every problem in $class.NP$ can be solved in polynomial time. The class $class.NPcomplete$ is the intersection of $class.NP$ and $class.NPhard$.
  - $class.NP = class.P$ iff there exists a $class.NPcomplete$ problem that is in $class.P$.
  - The Cook-Levin theorem shows that the Boolean satisfiability problem (SAT) is $class.NPcomplete$.
]

= Randomized Algorithms

= Quantum Computation

= Average Case Complexity
