# Roadmap to Galois theory

In the following, `F`, `K`, `L` are fields.

## Polynomials

1. Division algorithm: for polynomials `p, d` in `F[X]` where `deg d > 0`, there is `q, r` such that `p = qd+r` where `r = 0` or `deg r < deg d`.

## Subrings and subfields

Let `F` be a subfield of `K` an `S` be a subset of `K`.

2. `F[S]` is the smallest subring of `K` that contains `F` and `S`, i.e. the subring generated by `F` and `S`.
3. Concretely, elements of `F[S]` are `F`-linear combinations of products of powers of elements of `S`. An example would be `a1 s1^3 s3^2 + a2 s2` where `a1` and `a2` are in `F`, and `s1` to `s3` are in `S`.
4. `F(S)` is the smallest subfield of `K` that contains `F` and `S`, i.e. the subfield generated by `F` and `S`.
5. `F(S)` is then also the smallest subfield of `K` containing `F[S]`, so its elements can be described as `x/y` where `x` and `y` are elements of `F[S]`.
6. By abuse of notation, if `a1, ..., an` are elements of `K`, then `F[a1, ..., an] := F[{a1, ..., an}]` and `F(a1, ..., an) := F({a1, ..., an})`.
7. For chosen `a1, ..., an` we have a canonical surjection `F[X1, ..., Xn] -> F[a1, ..., an]` that is the evaluation map, sending `f` in `F[X1, ..., Xn]` to `f(a1, ..., an)`.

## Minimal polynomial

8. For `a` in `K` we have a canonical surjection `phi : F[X] -> F[a]`. That the kernel is non-trivial is equivalent to that `a` is a root of some non-zero polynomial, which means that `a` is algebraic.
9. In that case, `F[a] = F(a)` (use Cayley-Hamilton, or not, or finite dimensional integral domain is field (thanks Kevin!)).
10. If `a` is algebraic, then `ker phi` is a non-zero ideal of `F[X]` (concretely, it is the set of all polynomials that have `a` as a root). Then there is a unique monic polynomial in `ker phi` of the lowest degree, which we call `irr(a,F)`.
11. An equivalent characterisation of `irr(a,F)` is that it is the unique monic polynomial such that for any polynomial `f` in `F[X]`, `f(a) = 0` iff `irr(a,F) | f`.
12. `irr(a,F)` is irreducible.
13. `irr(a,F)` generates `ker phi`, so `F(a) = F[X]/(irr(a,F))`.
14. Two elements in `K` with the same minimal polynomial are called conjugates.

## Field extensions

15. `K/F` being a field extension is equivalent to `F` being a subfield of `K`, which is equivalent to having a map `F -> K`.
16. Field extensions are vector spaces. The dimension is called the degree, notated `[K:F]`.
17. Tower law: `[L:F] = [L:K] [K:F]`.

## Adjoining one root

18. If `p` is an irreducible polynomial in `F[X]` then `F[X]/(p)` is a field extension of `F` of degree `deg p` that contains a root of `p`.
19. If `p` is a polynomial in `F[X]` then let `p1` be one of the irreducible factors of `p` and then `F[X]/(p1)` contains a root of `p`.

## Splitting fields

20. For any `p` in `F[X]` there is a field extension `K/F` of degree dividing `(deg p)!` that contains all roots of `p`.
21. Suppose `K/F` and `L/F` are extensions, and `K=F(a1, ..., an)` where `irr(ai,F)` splits in `L` for every `i`. Then there is a map `K -> L` that fixes `F`.
22. Suppose `K/F` is an extension containing all roots of `p`, so `p = prod (X-ai)` in `K`. Then, `F(a1, ..., an)` is called the splitting field of `p` over `F`.
23. Suppose `K/F` and `L/F` are two extensions containing all roots of `p`, so `p = prod (X-ai)` in `K` and `p = prod (X-bi)` in `K`. Then `F(a1, ..., an)` is isomorphic to `F(b1, ..., bn)` in a way that fixes `F`.
24. Suppose `phi : F -> F'` and `K/F` is the splitting field of `p` and `K'/F'` is the splitting field of `phi(p)`, then `K` is isomorphic to `K'` in a way that restricts to `phi`.
25. Suppose `K/F` is an extension where `p = prod (X-ai)`. Suppose `L/F` is another extension. Suppose we have two maps `s, t : K -> L` that fixes `F`. Then `s(K) = t(K)` as sets.

## Normal extensions

26. We call an extension `K/F` normal iff every irreducible polynomial `p` in `F[X]` either has no roots in `K` or splits in `K`.
27. Equivalently, for every `a` in `K`, `irr(a,F)` splits in `K`.
28. For a finite extension `K/F`, it is normal iff it is the splitting field of some `h` in `F[X]`.
29. We call `N/F` a normal closure of `K/F` if it is the "smallest" normal extension containing `K`. That means, `N/F` is normal, and for any `L/K` such that `L/F` is normal, there is a map `N -> L` that fixes `K`.
30. Normal closures exist, and any two normal closures are isomorphic. Call it `N(K)`.
31. Let `a` in `K` and `b` be a conjugate of `a`. Then there is a map `N(K) -> N(K)` sending `a` to `b` and fixing `F`.
32. Let `L` be an extension of `N(K)`. Any map `K -> L` that fixes `F` has image contained in `N(K)`.
33. Let `N/K` such that `N/F` is normal, and let `L/N`. Any map `K -> L` that fixes `F` has image contained in `N`.
34. If `L/F` is normal then `L/K` is also normal.

## Separable polynomials

35. Resultant of two polynomials.
36. Discriminant of a polynomial.
37. `f` in `F[X]` is separable := `discriminant(f)` is non-zero.
38. If `f` is irreducible, then `f` is separable iff `gcd(f,Df)=1`.
39. `f` is separable iff it has no double root in every extension in which it splits.

## Dedekind's lemma

40. If `K` and `L` are fields then maps `K -> L` are linearly independent over `L`.

## Separable extensions

41. We call an extension `K/F` separable iff `irr(a,F)` is separable for any `a` in `K`.
42. For a finite extension `K/F`, define the separability degree `Sep(K/F)` to be the number of maps from `K` to `N(K)` that fix `F`.
43. For any extension `L/K` such that `L/F` is normal, `Sep(K/F)` is also the number of maps from `K` to `L` that fix `F`.
44. `Sep(K/F) <= [K:F]`
45. Tower law: `Sep(L/F) = Sep(L/K) Sep(K/F)`.
46. `Sep(F(a)/F) = [F(a):F]` iff `a` is separable.
47. `Sep(K/F) = [K:F]` iff `K` is separable.
48. `L/F` is separable iff `L/K` and `K/F` are separable.

## Galois extensions

49. Call `K/F` Galois iff it is normal and separable.
50. In that case, `Gal(K/F)` is the group of automorphisms of `K` that fix `F`, called the Galois group.
51. In that case, `|Gal(K/F)| = [K:F]`.

## Unnamed lemma

52. If `F` is a field and `H` is a finite subgroup of automorphisms of `F`, then `F^H` is Galois and `[F:F^H] = |H|`.

## Fundamentel theorem of Galois theory

53. If `L/F` is finite Galois with Galois group `G` then there is a `G`-equivariant lattice anti-isomorphism between the intermediate extensions of `L/F` and subgroups of `G`, sending an intermediate extension `K` to `Gal(L/K)` and sending a subgroup `H` to `L^H`.