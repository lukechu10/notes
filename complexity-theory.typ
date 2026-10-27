#import "utils/template.typ": *
#import "utils/complexity-classes.typ" as class

#show: template

#set document(
  title: "Notes on Complexity Theory",
  author: "Luke Chu",
)

// Document start

#title()
_Luke Chu #h(3em) Last updated: #datetime.today().display()_

These notes cover the basics of complexity theory, building up to the theory of average-case complexity, and in particular, to the theory of quantum average-case complexity.
The sections on basic complexity classes, the polynomial hierarchy, and boolean circuits are based on the book _Computational Complexity: A Modern Approach_ by Sanjeev Arora and Boaz Barak @Arora_Barak_2009.
The section on average case complexity is primarily based on _Average-Case Complexity_ by Andrej Bogdanov and Luca Trevisan @Bogdanov_Trevisan_2021.

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
  A more natural example of an uncomputable function is the _halting problem_, which is the function $"HALT": {0, 1}^* -> {0, 1}$ which returns 1 if the TM represented by the input string halts on that input, and returns 0 otherwise.

  If we had a TM $M_"Halt"$ that computes $"HALT"$, we could use it to compute the function $f$ defined in the proof of @thm:uncomputable-function, which is a contradiction. The idea is that we can use $M_"Halt"$ to first determine whether some TM $M_x$ halts on input $x$. If it does not halt, we can immediately return 0. If it does halt, we can simulate $M_x$ on input $x$ using the universal TM to determine what it returns.

  Therefore, the halting problem is uncomputable.
]

== The Complexity Class $class.P$

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

== The Complexity Class $class.NP$

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

== The Complexity Class $class.coNP$

Given some language $L subset.eq {0, 1}^*$, we can define its complement language $overline(L) = {0, 1}^* \\ L$.

This allows us to define the complexity class $class.coNP$ as follows.
$ class.coNP = { L subset.eq {0, 1}^* | overline(L) in class.NP }. $

Similarly to how we defined $class.NP$ in terms of certificates and verifiers, we can do the same for $class.coNP$.

#definition[The class $class.coNP$][
  A language $L$ is in $class.coNP$ if there exists a polynomial $p(n)$ and a polynomial-time TM $M$ such that $forall x in {0, 1}^*, x in L$ iff $forall u in {0, 1}^p(|x|)$ such that $M(x, u) = 1$.
]

TODO: finish section on $class.coNP$.

#emph-block[
  *Summary*:
  - The notion of _computability_ is formalised using Turing Machines. Not all functions are computable, and the halting problem is a canonical example of an uncomputable function.
  - We often work in the framework of _decision problems_ and _languages_. These decision problems can be classified into _complexity classes_, based on the resources required to solve them. The most fundamental complexity classes are $class.P$ and $class.NP$ which represent problems that can be solved in polynomial time and problems whose solutions can be verified in polynomial time, respectively. The question of whether $class.P = class.NP$ is one of the most important open questions in computer science.
  - Some problems in $class.NP$ are $class.NPhard$, meaning that they are the "hardest" problems in $class.NP$. If any $class.NPhard$ problem can be solved in polynomial time, then every problem in $class.NP$ can be solved in polynomial time. The class $class.NPcomplete$ is the intersection of $class.NP$ and $class.NPhard$.
  - $class.NP = class.P$ iff there exists a $class.NPcomplete$ problem that is in $class.P$.
  - The Cook-Levin theorem shows that the Boolean satisfiability problem (SAT) is $class.NPcomplete$.
]

= The Polynomial Hierarchy

The _polynomial hierarchy_, or $class.PH$, is a hierarchy of complexity classes that generalizes the classes $class.P$, $class.NP$, and $class.coNP$. One way to define the polynomial hierarchy is using alternating quantifiers.

== The Complexity Class $Sigma_2^P$

To motivate the study of $class.PH$, consider the following problem. We know that the problem of determining whether a graph $G$ has an independent set of size $k$ is in $class.NP$.

$ "INDSET" = { (G, k) | G "has an independent set of size" >= k }. $

This problem is in $class.NP$ because we can clearly verify a certificate (the independent set) in polynomial time. However, consider now the "exact independent set" problem:

$ "EXACT-INDSET" = { (G, k) | "The maximum independent set of" G "is of size" k }. $

Here it doesn't seem like we can verify a certificate in polynomial time. In particular, we need to verify that there _exists_ an independent set of size $k$, and that _for all_ independent sets, they are at most of size $k$.

To capture this kind of problem, we introduce the class $Sigma_2^P$.

#definition[The class $Sigma_2^P$][
  A language $L$ is in $Sigma_2^P$ if there exists a polynomial $p(n)$ and a polynomial-time TM $M$ such that

  $
    forall x in {0, 1}^*, med x in L "iff" exists u in {0, 1}^p(|x|) med forall v in {0, 1}^p(|x|) "such that" M(x, u, v) = 1.
  $
]<def:sigma-2-P>

#remark[
  $Sigma_2^P$ clearly contains both $class.NP$ and $class.coNP$ since we can construct $M$ to ignore either $u$ or $v$.
]

#example[
  The "exact independent set" problem described above is in $Sigma_2^P$ since we can take $u$ to be a independent set of size $k$, and $v$ to be any independent set. The verifier $M$ can then check that $u$ is indeed an independent set of size $k$ and that $v$ is not an independent set of size greater than $k$.
]

== The Polynomial Hierarchy

To define the polynomial hierarchy, we can define a sequence of classes $Sigma_k^P$ and $Pi_k^P$ for $k >= 0$ as follows:

#definition[The classes $Sigma_k^P$ and $Pi_k^P$][
  - $Sigma_0^P = Pi_0^P = class.P$.
  - For $k >= 1$, a language $L$ is in $Sigma_k^P$ if there exists a polynomial $p(n)$ and a polynomial-time TM $M$ such that $forall x in {0, 1}^*$,
    $
      x in L "iff" exists u_1 in {0, 1}^p(|x|) med forall u_2 in {0, 1}^p(|x|) med ... med Q_k u_k in {0, 1}^p(|x|) med M(x, u_1, ..., u_k) = 1,
    $
    where $Q_k$ is an existential quantifier if $k$ is odd and a universal quantifier if $k$ is even.
  - For $k >= 1$, a language $L$ is in $Pi_k^P$ if there exists a polynomial $p(n)$ and a polynomial-time TM $M$ such that $forall x in {0, 1}^*$,
    $
      x in L "iff" forall u_1 in {0, 1}^p(|x|) med exists u_2 in {0, 1}^p(|x|) med ... med Q_k u_k in {0, 1}^p(|x|) med M(x, u_1, ..., u_k) = 1,
    $
    where $Q_k$ is an existential quantifier if $k$ is even and a universal quantifier if $k$ is odd.
]

Note that $Sigma_1^P = class.NP$ and $Pi_1^P = class.coNP$.

We are now ready to define the polynomial hierarchy.

#definition[The polynomial hierarchy $class.PH$][
  $class.PH = union.big_(k >= 0) Sigma_k^P$.
]

#lemma[
  $class.PH = union.big_(k >= 0) Pi_k^P$.
]
#proof[
  This follows from the fact that $Sigma_k^P subset.eq Pi_(k+1)^P subset.eq Sigma_(k+2)^P$.
]

== Properties of the Polynomial Hierarchy

We believe that $class.NP != class.coNP$. We can generalize this to the conjecture that $Sigma_k^P != Sigma_(k+1)^P$ for all $k >= 1$. This is often stated as _the polynomial hierarchy does not collapse_.

If for some $k$, $Sigma_k^P = Sigma_(k+1)^P$, then we say that _the polynomial hierarchy collapses to the $k$-th level_. This also implies that $class.PH = Sigma_k^P = union.big_(k >= 0) Sigma_k^P$.

#theorem[
  - For every $k > 0$, if $Sigma_k^P = Pi_k^P$, then $class.PH = Sigma_k^P$, i.e. the polynomial hierarchy collapses to the $k$-th level.
  - If $class.P = class.NP$, then $class.P = class.PH$, i.e. the polynomial hierarchy collapses to $class.P$.
]

#proof[
  TODO
]

Every level $Sigma_k^P$ and $Pi_k^P$ have complete problems. However, $class.PH$ itself does not have any complete problems unless the polynomial hierarchy collapses.

#property[
  If there exists a language $L$ that is $class.PH$-complete, then the polynomial hierarchy collapses to some level $k$.
]
#proof[
  If $L in class.PH$ is $class.PH$-complete, then $L in Sigma_k^P$ for some finite $k$. But by definition of $class.PH$-completeness, all languages in $class.PH$ are polynomial-time reducible to $L$. Therefore, every language $L' in class.PH$ is in $Sigma_k^P$, which implies that $class.PH$ collapses to the $k$-th level.
]

#property[
  $class.PH subset.eq class.PSPACE$.
]

#corollary[
  $class.PH != class.PSPACE$ unless the polynomial hierarchy collapses to some level $k$.
]

#proof[
  $class.PSPACE$ has complete problems, but $class.PH$ does not have any complete problems unless it collapses to some level $k$.
]

#remark[
  Similar to non-deterministic Turing Machines, we can also define _alternating Turing Machines_, or ATMs which can be used to model the polynomial hierarchy.

  Recall that a non-deterministic Turing Machine accepts if there exists some sequence of non-deterministic choices that leads to acceptance. An alternating Turing Machine generalizes this by allowing both existential and universal states. Each state of the ATM is labelled as either existential or universal. The ATM accepts if there exists a sequence of choices that leads to acceptance, where the choices at existential states are existentially quantified and the choices at universal states are universally quantified.

  We can then define $class.PH$ in terms of ATMs who only have a fixed number of alternations between existential and universal states.

  We can also define classes such as $class.ATIME(T(n))$ and $class.AP = union_(c in NN) class.ATIME(n^c)$. In particular, these classes allow unbounded number of alternations between existential and universal quantifiers. We can show that $class.AP = class.PSPACE$.
]

#remark[
  Finally, it should be noted that the polynomial hierarchy can also be defined in terms of oracle Turing Machines. In particular, we have $Sigma_k^P = class.NP^(Sigma_(k-1)^P)$, and $Pi_k^P = class.coNP^(Sigma(k-1)^P)$.
]

#emph-block[
  *Summary*:
  - The polynomial hierarchy $class.PH$ is a hierarchy of complexity classes that generalizes $class.P$, $class.NP$, and $class.coNP$. It is defined using alternating quantifiers, and can also be defined in terms of alternating Turing Machines.
  - The polynomial hierarchy is believed to not collapse, i.e. $Sigma_k^P != Sigma_(k+1)^P$ for all $k >= 1$. If it does collapse, then it collapses to some level $k$.
  - Every level of the polynomial hierarchy has complete problems, but the polynomial hierarchy itself does not have any complete problems unless it collapses to some level $k$.
]

= Boolean Circuits

= Randomized Algorithms

We would like to investigate the power of Turing Machines that are allowed to make random coin tosses.

= Average Case Complexity

== Distributional Problems

== Average Polynomial Time

=== The Complexity Class $class.AvgP$

A naive way to define average polynomial time is to say that a distributional problem $(L, D)$ is average polynomial-time solvable if the _expected running time_ of the algorithm $A$ is polynomial in the size of the input. That is, if $A$ satisfies the following condition:
$ EE_(x tilde D_n)[t_A (x)] = "poly"(n). $

However, this definition does not seem to properly capture the notion of "efficient on average". Consider the following example. Let $(L, D)$ be a distributional problem that can be solved by some algorithm $A$ in polynomial time for $1-2^(-n)$ of the inputs of length $n$, but takes exponential time $2^n$ for the remaining $2^(-n)$ inputs. This has expected running time:
$
  EE_(x tilde D_n)[t_A (x)] & = (1-2^(-n)) dot "poly"(n) + 2^(-n) dot 2^n \
                            & = "poly"(n) + O(1).
$

Now consider some other algorithm $B$ that solves the same problem but is quadratically slower than $A$ on all inputs. That is, $t_B (x) = t_A (x)^2$. We would still expect $B$ to be considered average polynomial-time solvable, since it is only quadratically slower than $A$. However, the expected running time of $B$ is:
$
  EE_(x tilde D_n)[t_B (x)] = EE_(x tilde D_n)[t_A (x)^2] & = (1-2^(-n)) dot "poly"(n)^2 + 2^(-n) dot 2^(2n) \
                                                          & = O(2^n).
$
So $B$ would not be considered average polynomial-time solvable under this definition.

Instead, we can define average polynomial time in terms of a polynomial trade-off between the running time and fraction of inputs that the algorithm runs in polynomial time. This motivates the following definition of average polynomial time.

#definition[Average polynomial time, trade-off definition][
  An algorithm $A$ is said to run in _average polynomial time_ for a distribution $D$ if there exists some $epsilon > 0$ and some polynomial $p(n)$ such that for all $t$,
  $ Pr_(x tilde D_n)[t_A (x) >= t] <= p(n)/t^epsilon. $
]<def:avg-poly-time>

#remark[
  This definition bears strong resemblance to Markov's inequality, which states that for a non-negative random variable $X$ and any $a > 0$, we have
  $ Pr(X >= a) <= EE[X]/a. $

  TODO: reason out what the intuitive significance of this connection is.
]

#lemma[
  An algorithm $A$ runs in average polynomial time (according to @def:avg-poly-time) iff it satisfies the following condition for some $epsilon > 0$:
  $ EE_(x tilde D_n)[t_A (x)^epsilon] = O(n). $

  Furthermore, $O(n)$ can be replaced by any polynomial in $n$.
]

#proof[TODO]

This provides an alternative definition of average polynomial time that is equivalent to @def:avg-poly-time.

TODO: complete section

We can also define the notion of average polynomial time using _errorless heuristic schemes_.

#definition[Errorless heuristic scheme, the class $class.AvgP$][
  An _errorless heuristic scheme_ for a distributional problem $(L, D)$ is an algorithm $A(x, delta)$ that takes as input an instance $x$ and a parameter $delta in (0, 1)$, and outputs either $L(x)$ or a special symbol $bot$ indicating that it failed to solve the problem. The algorithm is allowed to fail with probability at most $delta$ over the choice of $x$ from the distribution $D_n$, where $n = |x|$.

  In particular, we say that a distributional problem $(L, D)$ is polynomial-time solvable on average if there exists an algorithm $A(x, delta)$ such that:
  - (Effectiveness) $A(x, delta)$ runs in time $"poly"(x/delta)$.
  - (Correctness) $forall x, A(x, delta) in {L(x), bot}$.
  - (Usefullness) $Pr_(x tilde D_n)(A(x, delta) = bot) < delta$

  Such a problem is said to be in the class $class.AvgP$.

]

=== The Complexity Class $class.AvgBPP$

We can relax the condition that the algorithm $A$ is errorless, and allow it to make bounded errors. This gives us the class $class.AvgBPP$.

#definition[The class $class.AvgBPP$][
  A distributional problem $(L, D)$ is in $class.AvgBPP$ if there exists a randomized algorithm $A(x, delta)$ such that:
  - (Effectiveness) $A(x, delta)$ runs in time $"poly"(x/delta)$.
  - (Correctness) $forall x, Pr(A(x, delta) in.not {L(x), bot}) <= 1/4$.
  - (Usefullness) $Pr_(x tilde D_n)(Pr_A (A(x, delta) = bot) >= 1/4) < delta$.
  For the final condition, note that the outer probability is over the choice of $x$ from the distribution $D_n$, while the inner probability is over the internal coin tosses of $A$.

  The algorithm $A$ is also called a _randomized errorless heuristic scheme_ for $(L, D)$. In this case, "errorless" refers to the proportion of inputs for which the algorithm fails (which can be made arbitrarily small), rather than the internal randomness of the algorithm.
]<def:AvgBPP>

#remark[@Itsykson_2010][
  The constant $1/4$ in the correctness and usefullness conditions are arbitrary and can be replaced by anything in the interval $(2^(-Omega(n)), 1/2)$.

  #proof[
    Suppose $(L, D)$ is in $class.AvgBPP$ with an algorithm $A(x, delta)$ satisfying definition @def:AvgBPP. We can construct a new algorithm $B(x, delta)$ as follows: on input $x$, we run $A(x, delta)$ for $n=|x|$ number of times and return the most frequent answer among ${bot, 0, 1}$.

    We now apply the Chernoff-Hoeffding bound which says that for $X_1, ... X_N$ independent and identically distributed random variables with $X_i in [0, 1]$ and $EE[X_i] = mu$, we have:
    $ Pr(abs((sum_i X_i)/N - mu)) >= epsilon) <= 2 e^(-2 n epsilon^2). $

    Applying this with $X_i tilde A(x, delta) = bot$, we get that if $Pr(A(x, delta) = bot) <= 1/4$ then $Pr(B(x, delta) = bot) = g(n)$, where $g(n) = 2^(-Omega(n))$ is some function.

    Therefore, we have
    $
      Pr_(x tilde D_n)(Pr_B (B(x, delta) = bot) >= g(n)) <= Pr_(x tilde D_n)(Pr_A (A(x, delta) = bot) >= 1/4) < delta.
    $
  ]
]

=== The Complexity Class $class.distNP$

TODO: $class.distNP := (class.NP, class.PComp)$.

== A Complete Problem for $class.distNP$

We introduce the _bounded halting problem_ which is complete for problems in $class.distNP$.

$ "BH" = {(M, x, 1^t) | M "is a Turing Machine that accepts x in time" <= t}. $

We pair this with the _approximately_ uniform distribution $U^"BH"$ and claim that the pair $("BH", U^"BH")$ is $class.distNP$-complete.

TODO: precise statement and theorem.

#proof[
  TODO
]

== A Complete Problem for $(class.NP, class.PSamp)$

== A Complete Problem for $class.AvgBPP$

There is currently no known complete problem for $class.BPP$ (although of course if $class.P = class.BPP$, then every $class.P$-complete problem is also $class.BPP$-complete). So somewhat surprisingly, we do know of a complete problem for the distributional class $(class.AvgBPP, class.PSamp)$#footnote[The notation $(class.AvgBPP, class.PSamp)$ denotes the distributional complexity class containing all $(L, D)$ in $class.AvgBPP$ where $D in class.PSamp$.], due to @Itsykson_2010.

Recall that the main obstacle to finding a complete problem for $class.BPP$ is the absence of an efficient enumeration of all bounded error probabilistic Turing Machines.
A language $L$ is in $class.BPP$ if there exists a probabilistic Turing Machine $M$ that accepts $x$ with probability at least $2/3$ if $x in L$, and accepts $x$ with probability at most $1/3$ if $x in.not L$. Thus there is a gap of $1/3$ between the acceptance and rejection probabilities. Since an arbitrary probabilistic Turing Machine can have some acceptance or rejection probability that lies somewhere in this gap for some inputs, not all probabilistic Turing Machines decide languages in $class.BPP$.
One way around this is to consider promise-$class.BPP$ instead, where we only consider inputs that are promised to have an acceptance or rejection probability that is bounded away from $1/2$.

So the problem is that some probabilistic Turing Machines are "troublesome" in that they do not have a clear majority answer for some inputs. In the distributional setting, we can take advantage of the distribution to construct a problem such that these "troublesome" machines are assigned a very small probability.

=== Reductions for $(class.AvgBPP, class.PSamp)$

We define a notion of deterministic, distributional Turing reduction for problems $(L, D)$ and $(L', D')$.

#definition[Deterministic Turing reduction][
  A distributional problem $(L, D)$ is _errorlessly reducible_ to a problem $(L', D')$ if $exists$ a deterministic polynomial-time Turing Machine $M(x; delta)$ equiped with an oracle for $L'$ such that:
  - (Effectiveness) $M(x; delta)$ runs in time $"poly"((|x|)/delta)$.
  - (Correctness) $forall x in "supp"(D), med M(x; delta) in {L(x), bot}$.
  - (Usefullness) $forall n, med Pr_(x tilde D_n)(M(x; delta) = bot) < delta$.
  - (Domination) There exists a polynomial $p(n)$ and a sequence of subsets $E_n subset.eq {0, 1}^n$ of small measure $D_n (E_n) < delta$ such that
    $
      forall y in {0, 1}^*, sum_(x in {0, 1}^* \\ E_n) "Ask"_(M, delta)(x, y) D_n(x) <= p(n/delta) D'(y),
    $
    where $"Ask"_(M, delta)(x, y)$ = 1 if $M(x; delta)$ queries the oracle for a string $y$ and 0 otherwise. $E_n$ can informally be thought of as the set of "bad" inputs for which the reduction does not work, and the domination condition ensures that these bad inputs do not have too much probability mass under the distribution $D_n$.

  If $(L, D)$ is errorlessly reducible to $(L', D')$, we write $(L, D) <=_T (L', D')$.
]<def:deterministic-turing-reduction-avgBPP>

#remark[
  The domination condition is reminiscent of the notion of _domination_ in the Levin-style many-to-one reductions for distributional problems.
  The difference here is that since we are using Turing reductions, the domination condition should be applied to the cases where we query the oracle, rather than on the inputs themselves.
]

This notion of reduction is relevant to $class.AvgBPP$ because of the following closure property.

#lemma[
  $class.AvgBPP$ is closed under reductions as defined in @def:deterministic-turing-reduction-avgBPP.
  In other words, if $(L, D) <=_T (L', D')$ and $(L', D') in class.AvgBPP$, then $(L, D) in class.AvgBPP$.
]

#remark[
  Similar to how $class.P$ is closed under polynomial-time Turing reductions (since $class.P = class.P^class.P$), $class.AvgBPP$ is closed under deterministic distributional polynomial-time Turing reductions.

  This is in contrast to classes like $class.NP$ which are not closed under polynomial-time Turing reductions, since this would correspond to the class $class.P^class.NP$ which is strictly bigger than $class.NP$ unless the polynomial hierarchy collapses.
]

=== The Complete Language

We introduce some arbitrary parameter $0 < epsilon < 1/10$ with the following interpretation:
- $lambda = 5 epsilon$: probability of $bot$ above which we return the fallback bit,
- $a_0 = 1-5 epsilon$: boundary used in the correctness argument,
- $a_1 = 1-4 epsilon$: threshold for decision algorithm,
- $a_2 = 1-3 epsilon$: boundary for statistically bad inputs,
- $a_3 = 1-2 epsilon$: acceptance threshold of the distribution sampler,
- $a_4 = 1-epsilon$: probability guaranteeing that the sampler accepts with high probability.
The actual values of these parameters is not so important#footnote[The values used in the original paper by Itsykson @Itsykson_2010 can be recovered by setting $lambda = 1/4$ and $epsilon = 1/20$.], as long as they satisfy the following inequality:
$ lambda < 1/2 < a_0 < a_1 < a_2 < a_3 < a_4 < 1. $

We will now describe a complete distributional problem $(C, R)$ for $(class.AvgBPP, class.PSamp)$.

Let $M^(<=m)$ denote the probabilistic Turing Machine $M$ that is restricted to run for at most $m$ steps. If $M$ has not halted after $m$ steps, it outputs the failure symbol $bot$.

Let $"freq"(M(x))$ denote the most frequent output of $M$ on input $x$ over all possible internal coin tosses of $M$, and let $p(M(x))$ be the probability of $"freq"(M(x))$.

All strings in $C$ have the form $(M, y, 1^m, b, S, 1^s)$, where:
- $M$ is a probabilistic Turing Machine,
- $y$ is an input string to $M$,
- $m$ is the maximum steps that $M$ can take,
- $b in {0, 1}$ is the answer that would be used instead of $bot$ for the machine $M^(<=m)$,
- $S$ is the encoding of a sampler,
- $1^s$ is the maximum steps that $S$ can take.
The language $C$ is defined by the following characteristic function:
$
  C(M, y, 1^m, b, S, 1^s) = cases(b &"if" quad Pr_M (M^(<=m)(y) = bot) >= lambda",", "freq"(M^(<=m)(y)) quad &"if" quad Pr_M (M^(<=m)(y) = bot) < lambda.)
$

In particular, we can decide $C$ by a deterministic algorithm simply by checking every possible sequence of coin tosses of $M^(<=m)$ to determine the most frequent output.

We now introduce a sampling algorithm $R$, which we claim satisfies the condition that $(C, R) in (class.AvgBPP, class.PSamp)$.
#algorithm[The sampling algorithm $R$][
  - Generate a string $w$ of length $n$ and interpret it as $(M, y, r, b, S, sigma)$, where $b in {0, 1}$. If $w$ is not of this form, return $w$.
  - Run the sampler $S^(<=abs(sigma))(1^abs(y))$ to obtain $x$. If it fails to output a string of length $abs(y)$, return $1^n$.
  - Run $M^(<=abs(r))(x)$ for $K_R(n) = ceil((5 n ln 2)/(2 epsilon^2))$ times. If neither 0 or 1 is returned at least $a_3$ of the time, return $1^n$.
  - Otherwise, return $(M, x, 1^abs(r), b, S, 1^abs(sigma))$.
]

Let $H$ be the distribution ensemble generated by the sampling algorithm $R$.

#lemma[Sampling lemma][
  The sampler $R$ runs in polynomial time and satisifies the following properties:
  + Small probability of bad inputs:
    for every well-formed input, if $p(M^(<=m) (x)) <= a_2$, then $R_n (z) <= 2^(-4n)$.
  + Domination of good inputs:
    let $S$ be a sampler for $D$, and asume $S(1^abs(x))$ always halts within $s$ steps.
    Then if $p(M^(<=m) (x)) >= a_4$, then $R_n (z) >= 1/2 D_abs(x) (x) 2^(-abs(M) - abs(S) - 1- h)$, where $h$ is some encoding overhead for the 6-tuple.
  + Membership in $class.AvgBPP$:
    the distributional problem $(C, H)$ is in $class.AvgBPP$.
]

#proof[
  To show that $(C, H) in class.AvgBPP$, we can explicitly construct an $class.AvgBPP$ algorithm $A(z; delta)$ as follows.

  We choose some constant number of repetitions
  $ K = ceil((ln 64)/(2 epsilon^2)). $

  On input $(z; delta)$, where $z = (M, y, 1^m, b, S, 1^s)$, we run the following procedure:
  - If $delta <= 2^(-n)$, enumerate all random choices of $M^(<=m)(y)$, calculate its exact probability, and return $C(z)$.
  - If $delta > 2^(-n)$, we execute $M^(<=m)(y)$ independently for $K$ times. Return $c in {0, 1}$ if it appears in at least $a_1$ fraction of the executions, and return $bot$ otherwise.

  Crucially, $K$ is independent of both $m$ and $n$.

  To show that this algorithm is in $class.AvgBPP$ (according to @def:AvgBPP), we need to show that it satisfies the effectiveness, correctness, and usefullness conditions.
  - (Effectiveness) If $delta <= 2^(-n)$, since $M$ runs for at most $m$ steps, it uses at most $O(m)$ random bits. There are at most $2^O(m)$ possible sequences of coin tosses so we can enumerate all of them in that time. Simulating each round is polynomial in $n$ (which also includes the description of $M$), so the total running time is $t(z; delta) <= 2^O(m) "poly"(n)$. This is polynomial in $n/delta$ since $m <= n$ and $2^n <= 1/delta$.

    For the other case, if $delta > 2^(-n)$, we run $K = O(1)$ executions which is independent of $n$ and $delta$.
]

#theorem[
  $(C, H)$ is complete for $(class.AvgBPP, class.PSamp)$ under deterministic Turing reductions as defined in @def:deterministic-turing-reduction-avgBPP.
]

#emph-block[
  *Summary*:
  - Average case complexity is a framework for studying the complexity of problems under some distribution over the inputs. The central objects of study are _distributional problems_ $(L, D)$, where $L$ is a language and $D$ is an ensemble of distributions over the inputs.
  - TODO: finish summary
]


= Quantum Average Case Complexity

= Examples of Quantum Average Case Complexity

== Random Hamiltonian Simulation

#let bib = ```bib
 @book{Arora_Barak_2009, title={Computational Complexity}, author={Arora, Sanjeev and Barak, Boaz}, language={en}, year={2009}, isbn={9780521424264} }

 @article{Bogdanov_Trevisan_2021, title={Average-Case Complexity}, url={http://arxiv.org/abs/cs/0606037}, DOI={10.48550/arXiv.cs/0606037}, note={arXiv:cs/0606037}, number={arXiv:cs/0606037}, publisher={arXiv}, author={Bogdanov, Andrej and Trevisan, Luca}, year={2021}, month=aug, language={en} }

 @article{Itsykson_2010, title={Structural complexity of AvgBPP}, volume={162}, ISSN={0168-0072}, DOI={10.1016/j.apal.2010.09.006}, number={3}, journal={Annals of Pure and Applied Logic}, author={Itsykson, Dmitry}, year={2010}, month=dec, pages={213–223} }

```

#bibliography(bytes(bib.text), full: true, style: "ieee")
