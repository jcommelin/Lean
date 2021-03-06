import data.padics.padic_norm data.nat.binomial

universes u v

theorem inv_pow' {α : Type u} [discrete_field α] {x : α} {n : ℕ} : (x⁻¹)^n = (x^n)⁻¹ :=
decidable.by_cases
  (assume H : x = 0, or.cases_on (nat.eq_zero_or_pos n)
    (λ hn, by rw [H, hn, pow_zero, pow_zero, inv_one])
    (λ hn, by rw [H, zero_pow hn, inv_zero, zero_pow hn]))
  (λ H, division_ring.inv_pow H n)

theorem pow_eq_zero {α : Type u} [domain α] {x : α} {n : ℕ} (H : x^n = 0) : x = 0 :=
begin
  induction n with n ih,
  { rw pow_zero at H,
    rw [← mul_one x, H, mul_zero] },
  exact or.cases_on (mul_eq_zero.1 H) id ih
end

class char_p (α : Type u) [semiring α] (p : ℕ) : Prop :=
(cast_eq_zero_iff : ∀ x:ℕ, (x:α) = 0 ↔ p ∣ x)

theorem char_p.cast_eq_zero (α : Type u) [semiring α] (p : ℕ) [char_p α p] : (p:α) = 0 :=
(char_p.cast_eq_zero_iff α p p).2 (dvd_refl p)

theorem char_p.eq (α : Type u) [semiring α] {p q : ℕ} (c1 : char_p α p) (c2 : char_p α q) : p = q :=
nat.dvd_antisymm
  ((char_p.cast_eq_zero_iff α p q).1 (char_p.cast_eq_zero _ _))
  ((char_p.cast_eq_zero_iff α q p).1 (char_p.cast_eq_zero _ _))

instance char_p.of_char_zero (α : Type u) [semiring α] [char_zero α] : char_p α 0 :=
⟨λ x, by rw [zero_dvd_iff, ← nat.cast_zero, nat.cast_inj]⟩

theorem char_p.exists (α : Type u) [semiring α] : ∃ p, char_p α p :=
by letI := classical.dec_eq α; exact
classical.by_cases
  (assume H : ∀ p:ℕ, (p:α) = 0 → p = 0, ⟨0,
    ⟨λ x, by rw [zero_dvd_iff]; exact ⟨H x, by rintro rfl; refl⟩⟩⟩)
  (λ H, ⟨nat.find (classical.not_forall.1 H), ⟨λ x,
    ⟨λ H1, nat.dvd_of_mod_eq_zero (by_contradiction $ λ H2,
      nat.find_min (classical.not_forall.1 H)
        (nat.mod_lt x $ nat.pos_of_ne_zero $ not_of_not_imp $
          nat.find_spec (classical.not_forall.1 H))
        (not_imp_of_and_not ⟨by rwa [← nat.mod_add_div x (nat.find (classical.not_forall.1 H)),
          nat.cast_add, nat.cast_mul, of_not_not (not_not_of_not_imp $ nat.find_spec (classical.not_forall.1 H)),
          zero_mul, add_zero] at H1, H2⟩)),
    λ H1, by rw [← nat.mul_div_cancel' H1, nat.cast_mul,
      of_not_not (not_not_of_not_imp $ nat.find_spec (classical.not_forall.1 H)), zero_mul]⟩⟩⟩)

theorem char_p.exists_unique (α : Type u) [semiring α] : ∃! p, char_p α p :=
let ⟨c, H⟩ := char_p.exists α in ⟨c, H, λ y H2, char_p.eq α H2 H⟩

noncomputable def ring_char (α : Type u) [semiring α] : ℕ :=
classical.some (char_p.exists_unique α)

theorem ring_char.spec (α : Type u) [semiring α] : ∀ x:ℕ, (x:α) = 0 ↔ ring_char α ∣ x :=
by letI := (classical.some_spec (char_p.exists_unique α)).1;
unfold ring_char; exact char_p.cast_eq_zero_iff α (ring_char α)

theorem ring_char.eq (α : Type u) [semiring α] {p : ℕ} (C : char_p α p) : p = ring_char α :=
(classical.some_spec (char_p.exists_unique α)).2 p C

theorem add_pow_char (α : Type u) [comm_ring α] {p : ℕ} (hp : nat.prime p)
  [char_p α p] (x y : α) : (x + y)^p = x^p + y^p :=
begin
  rw [add_pow, finset.sum_range_succ, nat.sub_self, pow_zero, choose_self],
  rw [nat.cast_one, mul_one, mul_one, add_left_inj],
  transitivity,
  { refine finset.sum_eq_single 0 _ _,
    { intros b h1 h2,
      have := nat.prime.dvd_choose (nat.pos_of_ne_zero h2) (finset.mem_range.1 h1) hp,
      rw [← nat.div_mul_cancel this, nat.cast_mul, char_p.cast_eq_zero α p],
      simp only [mul_zero] },
    { intro H, exfalso, apply H, exact finset.mem_range.2 hp.pos } },
  rw [pow_zero, nat.sub_zero, one_mul, choose_zero_right, nat.cast_one, mul_one]
end

theorem nat.iterate₀ {α : Type u} {op : α → α} {x : α} (H : op x = x) {n : ℕ} :
  op^[n] x = x :=
by induction n; [simp only [nat.iterate_zero], simp only [nat.iterate_succ', H, *]]

theorem nat.iterate₁ {α : Type u} {β : Type v} {op : α → α} {op' : β → β} {op'' : α → β}
  (H : ∀ x, op' (op'' x) = op'' (op x)) {n : ℕ} {x : α} :
  op'^[n] (op'' x) = op'' (op^[n] x) :=
by induction n; [simp only [nat.iterate_zero], simp only [nat.iterate_succ', H, *]]

theorem nat.iterate₂ {α : Type u} {op : α → α} {op' : α → α → α} (H : ∀ x y, op (op' x y) = op' (op x) (op y)) {n : ℕ} {x y : α} :
  op^[n] (op' x y) = op' (op^[n] x) (op^[n] y) :=
by induction n; [simp only [nat.iterate_zero], simp only [nat.iterate_succ', H, *]]

theorem nat.iterate_cancel {α : Type u} {op op' : α → α} (H : ∀ x, op (op' x) = x) {n : ℕ} {x : α} : op^[n] (op'^[n] x) = x :=
by induction n; [refl, rwa [nat.iterate_succ, nat.iterate_succ', H]]

theorem nat.iterate_inj {α : Type u} {op : α → α} (Hinj : function.injective op) (n : ℕ) (x y : α)
  (H : (op^[n] x) = (op^[n] y)) : x = y :=
by induction n with n ih; simp only [nat.iterate_zero, nat.iterate_succ'] at H;
[exact H, exact ih (Hinj H)]

def frobenius (α : Type u) [monoid α] (p : ℕ) (x : α) : α := x^p

theorem frobenius_def (α : Type u) [monoid α] (p : ℕ) (x : α) : frobenius α p x = x ^ p := rfl

theorem frobenius_mul (α : Type u) [comm_monoid α] (p : ℕ) (x y : α) :
  frobenius α p (x * y) = frobenius α p x * frobenius α p y := mul_pow x y p
theorem frobenius_one (α : Type u) [monoid α] (p : ℕ) :
  frobenius α p 1 = 1 := one_pow _

theorem is_monoid_hom.map_frobenius {α : Type u} {β : Type v} [monoid α] [monoid β] (f : α → β) [is_monoid_hom f]
  (p : ℕ) (x : α) : f (frobenius α p x) = frobenius β p (f x) :=
by unfold frobenius; induction p; simp only [pow_zero, pow_succ,
  is_monoid_hom.map_one f, is_monoid_hom.map_mul f, *]

instance {α : Type u} [comm_ring α] (p : ℕ) [hp : nat.prime p] [char_p α p] : is_ring_hom (frobenius α p) :=
{ map_one := frobenius_one α p,
  map_mul := frobenius_mul α p,
  map_add := add_pow_char α hp }

section
variables (α : Type u) [comm_ring α] (p : ℕ) [hp : nat.prime p]
theorem frobenius_zero : frobenius α p 0 = 0 := zero_pow hp.pos
variables [char_p α p] (x y : α)
include hp
theorem frobenius_add : frobenius α p (x + y) = frobenius α p x + frobenius α p y := is_ring_hom.map_add _
theorem frobenius_neg : frobenius α p (-x) = -frobenius α p x := is_ring_hom.map_neg _
theorem frobenius_sub : frobenius α p (x - y) = frobenius α p x - frobenius α p y := is_ring_hom.map_sub _
end

theorem frobenius_inj (α : Type u) [integral_domain α] (p : ℕ) [nat.prime p] [char_p α p] (x y : α)
  (H : frobenius α p x = frobenius α p y) : x = y :=
by rw ← sub_eq_zero at H ⊢; rw ← frobenius_sub at H; exact pow_eq_zero H

theorem frobenius_nat_cast (α : Type u) [comm_ring α] (p : ℕ) [nat.prime p] [char_p α p] (x : ℕ) :
  frobenius α p x = x :=
by induction x; simp only [nat.cast_zero, nat.cast_succ, frobenius_zero, frobenius_one, frobenius_add, *]

class perfect_field (α : Type u) [field α] (p : ℕ) [char_p α p] : Type u :=
(pth_root : α → α)
(frobenius_pth_root : ∀ x, frobenius α p (pth_root x) = x)

theorem frobenius_pth_root (α : Type u) [field α] (p : ℕ) [char_p α p] [perfect_field α p] (x : α) :
  frobenius α p (perfect_field.pth_root p x) = x :=
perfect_field.frobenius_pth_root p x

theorem pth_root_frobenius (α : Type u) [field α] (p : ℕ) [nat.prime p] [char_p α p] [perfect_field α p] (x : α) :
  perfect_field.pth_root p (frobenius α p x) = x :=
frobenius_inj α p _ _ (by rw frobenius_pth_root)

instance pth_root.is_ring_hom (α : Type u) [field α] (p : ℕ) [nat.prime p] [char_p α p] [perfect_field α p] :
  is_ring_hom (@perfect_field.pth_root α _ p _ _) :=
{ map_one := frobenius_inj α p _ _ (by rw [frobenius_pth_root, frobenius_one]),
  map_mul := λ x y, frobenius_inj α p _ _ (by simp only [frobenius_pth_root, frobenius_mul]),
  map_add := λ x y, frobenius_inj α p _ _ (by simp only [frobenius_pth_root, frobenius_add]) }

theorem is_ring_hom.pth_root {α : Type u} [field α] (p : ℕ) [nat.prime p] [char_p α p] [perfect_field α p]
  {β : Type v} [field β] [char_p β p] [perfect_field β p] (f : α → β) [is_ring_hom f] {x : α} :
  f (perfect_field.pth_root p x) = perfect_field.pth_root p (f x) :=
frobenius_inj β p _ _ (by rw [← is_monoid_hom.map_frobenius f, frobenius_pth_root, frobenius_pth_root])

inductive perfect_closure.r (α : Type u) [monoid α] (p : ℕ) : (ℕ × α) → (ℕ × α) → Prop
| intro : ∀ n x, perfect_closure.r (n, x) (n+1, frobenius α p x)
run_cmd tactic.mk_iff_of_inductive_prop `perfect_closure.r `perfect_closure.r_iff

def perfect_closure (α : Type u) [monoid α] (p : ℕ) : Type u :=
quot (perfect_closure.r α p)

namespace perfect_closure

variables (α : Type u)

private lemma mul_aux_left [comm_monoid α] (p : ℕ) (x1 x2 y : ℕ × α) (H : r α p x1 x2) :
  quot.mk (r α p) (x1.1 + y.1, ((frobenius α p)^[y.1] x1.2) * ((frobenius α p)^[x1.1] y.2)) =
  quot.mk (r α p) (x2.1 + y.1, ((frobenius α p)^[y.1] x2.2) * ((frobenius α p)^[x2.1] y.2)) :=
match x1, x2, H with
| _, _, r.intro _ n x := quot.sound $ by rw [← nat.iterate_succ, nat.iterate_succ',
    nat.iterate_succ', ← frobenius_mul, nat.succ_add]; apply r.intro
end

private lemma mul_aux_right [comm_monoid α] (p : ℕ) (x y1 y2 : ℕ × α) (H : r α p y1 y2) :
  quot.mk (r α p) (x.1 + y1.1, ((frobenius α p)^[y1.1] x.2) * ((frobenius α p)^[x.1] y1.2)) =
  quot.mk (r α p) (x.1 + y2.1, ((frobenius α p)^[y2.1] x.2) * ((frobenius α p)^[x.1] y2.2)) :=
match y1, y2, H with
| _, _, r.intro _ n y := quot.sound $ by rw [← nat.iterate_succ, nat.iterate_succ',
    nat.iterate_succ', ← frobenius_mul]; apply r.intro
end

instance [comm_monoid α] (p : ℕ) : has_mul (perfect_closure α p) :=
⟨quot.lift (λ x:ℕ×α, quot.lift (λ y:ℕ×α, quot.mk (r α p)
    (x.1 + y.1, ((frobenius α p)^[y.1] x.2) * ((frobenius α p)^[x.1] y.2))) (mul_aux_right α p x))
  (λ x1 x2 (H : r α p x1 x2), funext $ λ e, quot.induction_on e $ λ y,
mul_aux_left α p x1 x2 y H)⟩

instance [comm_monoid α] (p : ℕ) : comm_monoid (perfect_closure α p) :=
{ mul_assoc := λ e f g, quot.induction_on e $ λ ⟨m, x⟩, quot.induction_on f $ λ ⟨n, y⟩,
    quot.induction_on g $ λ ⟨s, z⟩, congr_arg (quot.mk _) $
    by simp only [add_assoc, mul_assoc, nat.iterate₂ (frobenius_mul _ _),
      (nat.iterate_add _ _ _ _).symm, add_comm, add_left_comm],
  one := quot.mk _ (0, 1),
  one_mul := λ e, quot.induction_on e (λ ⟨n, x⟩, congr_arg (quot.mk _) $
    by simp only [nat.iterate₀ (frobenius_one _ _), nat.iterate_zero, one_mul, zero_add]),
  mul_one := λ e, quot.induction_on e (λ ⟨n, x⟩, congr_arg (quot.mk _) $
    by simp only [nat.iterate₀ (frobenius_one _ _), nat.iterate_zero, mul_one, add_zero]),
  mul_comm := λ e f, quot.induction_on e (λ ⟨m, x⟩, quot.induction_on f (λ ⟨n, y⟩,
    congr_arg (quot.mk _) $ by simp only [add_comm, mul_comm])),
  .. (infer_instance : has_mul (perfect_closure α p)) }

private lemma add_aux_left [comm_ring α] (p : ℕ) (hp : nat.prime p) [char_p α p]
  (x1 x2 y : ℕ × α) (H : r α p x1 x2) :
  quot.mk (r α p) (x1.1 + y.1, ((frobenius α p)^[y.1] x1.2) + ((frobenius α p)^[x1.1] y.2)) =
  quot.mk (r α p) (x2.1 + y.1, ((frobenius α p)^[y.1] x2.2) + ((frobenius α p)^[x2.1] y.2)) :=
match x1, x2, H with
| _, _, r.intro _ n x := quot.sound $ by rw [← nat.iterate_succ, nat.iterate_succ',
    nat.iterate_succ', ← frobenius_add, nat.succ_add]; apply r.intro
end

private lemma add_aux_right [comm_ring α] (p : ℕ) (hp : nat.prime p) [char_p α p]
  (x y1 y2 : ℕ × α) (H : r α p y1 y2) :
  quot.mk (r α p) (x.1 + y1.1, ((frobenius α p)^[y1.1] x.2) + ((frobenius α p)^[x.1] y1.2)) =
  quot.mk (r α p) (x.1 + y2.1, ((frobenius α p)^[y2.1] x.2) + ((frobenius α p)^[x.1] y2.2)) :=
match y1, y2, H with
| _, _, r.intro _ n y := quot.sound $ by rw [← nat.iterate_succ, nat.iterate_succ',
    nat.iterate_succ', ← frobenius_add]; apply r.intro
end

instance [comm_ring α] (p : ℕ) [hp : nat.prime p] [char_p α p] : has_add (perfect_closure α p) :=
⟨quot.lift (λ x:ℕ×α, quot.lift (λ y:ℕ×α, quot.mk (r α p)
    (x.1 + y.1, ((frobenius α p)^[y.1] x.2) + ((frobenius α p)^[x.1] y.2))) (add_aux_right α p hp x))
  (λ x1 x2 (H : r α p x1 x2), funext $ λ e, quot.induction_on e $ λ y,
add_aux_left α p hp x1 x2 y H)⟩

instance [comm_ring α] (p : ℕ) [nat.prime p] [char_p α p] : has_neg (perfect_closure α p) :=
⟨quot.lift (λ x:ℕ×α, quot.mk (r α p) (x.1, -x.2)) (λ x y (H : r α p x y), match x, y, H with
| _, _, r.intro _ n x := quot.sound $ by rw ← frobenius_neg; apply r.intro
end)⟩

theorem mk_zero [comm_ring α] (p : ℕ) [nat.prime p] (n : ℕ) : quot.mk (r α p) (n, 0) = quot.mk (r α p) (0, 0) :=
by induction n with n ih; [refl, rw ← ih]; symmetry; apply quot.sound;
have := r.intro p n (0:α); rwa [frobenius_zero α p] at this

theorem r.sound [monoid α] (p m n : ℕ) (x y : α) (H : frobenius α p^[m] x = y) :
  quot.mk (r α p) (n, x) = quot.mk (r α p) (m + n, y) :=
by subst H; induction m with m ih; [simp only [zero_add, nat.iterate_zero],
  rw [ih, nat.succ_add, nat.iterate_succ']]; apply quot.sound; apply r.intro

instance [comm_ring α] (p : ℕ) [nat.prime p] [char_p α p] : comm_ring (perfect_closure α p) :=
{ add_assoc := λ e f g, quot.induction_on e $ λ ⟨m, x⟩, quot.induction_on f $ λ ⟨n, y⟩,
    quot.induction_on g $ λ ⟨s, z⟩, congr_arg (quot.mk _) $
    by simp only [add_assoc, nat.iterate₂ (frobenius_add α p),
      (nat.iterate_add _ _ _ _).symm, add_comm, add_left_comm],
  zero := quot.mk _ (0, 0),
  zero_add := λ e, quot.induction_on e (λ ⟨n, x⟩, congr_arg (quot.mk _) $
    by simp only [nat.iterate₀ (frobenius_zero α p), nat.iterate_zero, zero_add]),
  add_zero := λ e, quot.induction_on e (λ ⟨n, x⟩, congr_arg (quot.mk _) $
    by simp only [nat.iterate₀ (frobenius_zero α p), nat.iterate_zero, add_zero]),
  add_left_neg := λ e, quot.induction_on e (λ ⟨n, x⟩, show quot.mk _ _ = _,
    by simp only [nat.iterate₁ (frobenius_neg α p), add_left_neg, mk_zero]; refl),
  add_comm := λ e f, quot.induction_on e (λ ⟨m, x⟩, quot.induction_on f (λ ⟨n, y⟩,
    congr_arg (quot.mk _) $ by simp only [add_comm])),
  left_distrib := λ e f g, quot.induction_on e $ λ ⟨m, x⟩, quot.induction_on f $ λ ⟨n, y⟩,
    quot.induction_on g $ λ ⟨s, z⟩, show quot.mk _ _ = quot.mk _ _,
    by simp only [add_assoc, add_comm, add_left_comm]; apply r.sound;
    simp only [nat.iterate₂ (frobenius_mul α p), nat.iterate₂ (frobenius_add α p),
      (nat.iterate_add _ _ _ _).symm, mul_add, add_comm, add_left_comm],
  right_distrib := λ e f g, quot.induction_on e $ λ ⟨m, x⟩, quot.induction_on f $ λ ⟨n, y⟩,
    quot.induction_on g $ λ ⟨s, z⟩, show quot.mk _ _ = quot.mk _ _,
    by simp only [add_assoc, add_comm _ s, add_left_comm _ s]; apply r.sound;
    simp only [nat.iterate₂ (frobenius_mul α p), nat.iterate₂ (frobenius_add α p),
      (nat.iterate_add _ _ _ _).symm, add_mul, add_comm, add_left_comm],
  .. (infer_instance : has_add (perfect_closure α p)),
  .. (infer_instance : has_neg (perfect_closure α p)),
  .. (infer_instance : comm_monoid (perfect_closure α p)) }

instance [discrete_field α] (p : ℕ) [nat.prime p] [char_p α p] : has_inv (perfect_closure α p) :=
⟨quot.lift (λ x:ℕ×α, quot.mk (r α p) (x.1, x.2⁻¹)) (λ x y (H : r α p x y), match x, y, H with
| _, _, r.intro _ n x := quot.sound $ by simp only [frobenius]; rw [← inv_pow']; apply r.intro
end)⟩

theorem eq_iff' [comm_ring α] (p : ℕ) [nat.prime p] [char_p α p]
  (x y : ℕ × α) : quot.mk (r α p) x = quot.mk (r α p) y ↔
    ∃ z, (frobenius α p^[y.1 + z] x.2) = (frobenius α p^[x.1 + z] y.2) :=
begin
  split,
  { intro H,
    replace H := quot.exact _ H,
    induction H,
    case eqv_gen.rel : x y H
    { cases H with n x, exact ⟨0, rfl⟩ },
    case eqv_gen.refl : H
    { exact ⟨0, rfl⟩ },
    case eqv_gen.symm : x y H ih
    { cases ih with w ih, exact ⟨w, ih.symm⟩ },
    case eqv_gen.trans : x y z H1 H2 ih1 ih2
    { cases ih1 with z1 ih1,
      cases ih2 with z2 ih2,
      existsi z2+(y.1+z1),
      rw [← add_assoc, nat.iterate_add, ih1],
      rw [← nat.iterate_add, add_comm, nat.iterate_add, ih2],
      rw [← nat.iterate_add],
      simp only [add_comm, add_left_comm] } },
  intro H,
  cases x with m x,
  cases y with n y,
  cases H with z H, dsimp only at H,
  rw [r.sound α p (n+z) m x _ rfl, r.sound α p (m+z) n y _ rfl, H],
  rw [add_assoc, add_comm, add_comm z]
end

theorem eq_iff [integral_domain α] (p : ℕ) [nat.prime p] [char_p α p]
  (x y : ℕ × α) : quot.mk (r α p) x = quot.mk (r α p) y ↔
    (frobenius α p^[y.1] x.2) = (frobenius α p^[x.1] y.2) :=
(eq_iff' α p x y).trans ⟨λ ⟨z, H⟩, nat.iterate_inj (frobenius_inj α p) z _ _ $
  by simpa only [add_comm, nat.iterate_add] using H,
λ H, ⟨0, H⟩⟩

instance [discrete_field α] (p : ℕ) [nat.prime p] [char_p α p] : discrete_field (perfect_closure α p) :=
{ zero_ne_one := λ H, zero_ne_one ((eq_iff _ _ _ _).1 H),
  mul_inv_cancel := λ e, quot.induction_on e $ λ ⟨m, x⟩ H,
    have _ := mt (eq_iff _ _ _ _).2 H, (eq_iff _ _ _ _).2
      (by simp only [nat.iterate₀ (frobenius_one _ _), nat.iterate₀ (frobenius_zero α p),
        nat.iterate_zero, (nat.iterate₂ (frobenius_mul α p)).symm] at this ⊢;
        rw [mul_inv_cancel this, nat.iterate₀ (frobenius_one _ _)]),
  inv_mul_cancel := λ e, quot.induction_on e $ λ ⟨m, x⟩ H,
    have _ := mt (eq_iff _ _ _ _).2 H, (eq_iff _ _ _ _).2
      (by simp only [nat.iterate₀ (frobenius_one _ _), nat.iterate₀ (frobenius_zero α p),
        nat.iterate_zero, (nat.iterate₂ (frobenius_mul α p)).symm] at this ⊢;
        rw [inv_mul_cancel this, nat.iterate₀ (frobenius_one _ _)]),
  has_decidable_eq := λ e f, quot.rec_on_subsingleton e $ λ ⟨m, x⟩,
    quot.rec_on_subsingleton f $ λ ⟨n, y⟩,
    decidable_of_iff' _ (eq_iff α p _ _),
  inv_zero := congr_arg (quot.mk (r α p)) (by rw [inv_zero]),
  .. (infer_instance : has_inv (perfect_closure α p)),
  .. (infer_instance : comm_ring (perfect_closure α p)) }

theorem frobenius_mk [comm_monoid α] (p : ℕ) (x : ℕ × α) :
  frobenius (perfect_closure α p) p (quot.mk (r α p) x) = quot.mk _ (x.1, x.2^p) :=
begin
  unfold frobenius, cases x with n x, dsimp only,
  suffices : ∀ p':ℕ, (quot.mk (r α p) (n, x) ^ p' : perfect_closure α p) = quot.mk (r α p) (n, x ^ p'),
  { apply this },
  intro p, induction p with p ih,
  case nat.zero { apply r.sound, rw [nat.iterate₀ (frobenius_one _ _), pow_zero] },
  case nat.succ {
    rw [pow_succ, ih],
    symmetry,
    apply r.sound,
    simp only [pow_succ, nat.iterate₂ (frobenius_mul _ _)]
  }
end

def frobenius_equiv [comm_ring α] (p : ℕ) [nat.prime p] [char_p α p] :
  perfect_closure α p ≃ perfect_closure α p :=
{ to_fun := frobenius (perfect_closure α p) p,
  inv_fun := λ e, quot.lift_on e (λ x, quot.mk (r α p) (x.1 + 1, x.2)) (λ x y H,
    match x, y, H with
    | _, _, r.intro _ n x := quot.sound (r.intro _ _ _)
    end),
  left_inv := λ e, quot.induction_on e (λ ⟨m, x⟩, by rw frobenius_mk;
    symmetry; apply quot.sound; apply r.intro),
  right_inv := λ e, quot.induction_on e (λ ⟨m, x⟩, by rw frobenius_mk;
    symmetry; apply quot.sound; apply r.intro) }

theorem frobenius_equiv_apply [comm_ring α] (p : ℕ) [nat.prime p] [char_p α p] {x : perfect_closure α p} :
  frobenius_equiv α p x = frobenius _ p x :=
rfl

theorem nat_cast [comm_ring α] (p : ℕ) [nat.prime p] [char_p α p] (n x : ℕ) :
  (x : perfect_closure α p) = quot.mk (r α p) (n, x) :=
begin
  induction n with n ih,
  { induction x with x ih, {refl},
    rw [nat.cast_succ, nat.cast_succ, ih], refl },
  rw ih, apply quot.sound,
  conv {congr, skip, skip, rw ← frobenius_nat_cast α p x},
  apply r.intro
end

theorem int_cast [comm_ring α] (p : ℕ) [nat.prime p] [char_p α p] (x : ℤ) :
  (x : perfect_closure α p) = quot.mk (r α p) (0, x) :=
by induction x; simp only [int.cast_of_nat, int.cast_neg_succ_of_nat, nat_cast α p 0]; refl

theorem nat_cast_eq_iff [comm_ring α] (p : ℕ) [nat.prime p] [char_p α p] (x y : ℕ) :
  (x : perfect_closure α p) = y ↔ (x : α) = y :=
begin
  split; intro H,
  { rw [nat_cast α p 0, nat_cast α p 0, eq_iff'] at H,
    cases H with z H,
    simpa only [zero_add, nat.iterate₀ (frobenius_nat_cast α p _)] using H },
  rw [nat_cast α p 0, nat_cast α p 0, H]
end

instance [comm_ring α] (p : ℕ) [nat.prime p] [char_p α p] : char_p (perfect_closure α p) p :=
begin
  constructor, intro x, rw ← char_p.cast_eq_zero_iff α,
  rw [← nat.cast_zero, nat_cast_eq_iff, nat.cast_zero]
end

instance [discrete_field α] (p : ℕ) [nat.prime p] [char_p α p] : perfect_field (perfect_closure α p) p :=
{ pth_root := (frobenius_equiv α p).symm,
  frobenius_pth_root := (frobenius_equiv α p).apply_inverse_apply }

def of [monoid α] (p : ℕ) (x : α) : perfect_closure α p :=
quot.mk _ (0, x)

instance [comm_ring α] (p : ℕ) [nat.prime p] [char_p α p] : is_ring_hom (of α p) :=
{ map_one := rfl,
  map_mul := λ x y, rfl,
  map_add := λ x y, rfl }

theorem eq_pth_root [discrete_field α] (p : ℕ) [nat.prime p] [char_p α p] (m : ℕ) (x : α) :
  quot.mk (r α p) (m, x) = (perfect_field.pth_root p^[m] (of α p x) : perfect_closure α p) :=
begin
  unfold of,
  induction m with m ih, {refl},
  rw [nat.iterate_succ', ← ih]; refl
end

def UMP [discrete_field α] (p : ℕ) [nat.prime p] [char_p α p]
  (β : Type v) [discrete_field β] [char_p β p] [perfect_field β p] :
  { f : α → β // is_ring_hom f } ≃ { f : perfect_closure α p → β // is_ring_hom f } :=
{ to_fun := λ f, ⟨λ e, quot.lift_on e (λ x, perfect_field.pth_root p^[x.1] (f.1 x.2))
      (λ x y H, match x, y, H with | _, _, r.intro _ n x := by letI := f.2;
        simp only [is_monoid_hom.map_frobenius f.1, nat.iterate_succ, pth_root_frobenius]
      end),
    show f.1 1 = 1, from f.2.1,
    λ j k, quot.induction_on j $ λ ⟨m, x⟩, quot.induction_on k $ λ ⟨n, y⟩,
      show (perfect_field.pth_root p^[_] _) = (perfect_field.pth_root p^[_] _) * (perfect_field.pth_root p^[_] _),
      by letI := f.2; simp only [is_ring_hom.map_mul f.1, (nat.iterate₁ (λ x, (is_monoid_hom.map_frobenius f.1 p x).symm)).symm,
          @nat.iterate₂ β _ (*) (λ x y, is_ring_hom.map_mul (perfect_field.pth_root p))];
        rw [nat.iterate_add, nat.iterate_cancel (pth_root_frobenius β p),
          add_comm, nat.iterate_add, nat.iterate_cancel (pth_root_frobenius β p)],
    λ j k, quot.induction_on j $ λ ⟨m, x⟩, quot.induction_on k $ λ ⟨n, y⟩,
      show (perfect_field.pth_root p^[_] _) = (perfect_field.pth_root p^[_] _) + (perfect_field.pth_root p^[_] _),
      by letI := f.2; simp only [is_ring_hom.map_add f.1, (nat.iterate₁ (λ x, (is_monoid_hom.map_frobenius f.1 p x).symm)).symm,
          @nat.iterate₂ β _ (+) (λ x y, is_ring_hom.map_add (perfect_field.pth_root p))];
        rw [nat.iterate_add, nat.iterate_cancel (pth_root_frobenius β p),
          add_comm m, nat.iterate_add, nat.iterate_cancel (pth_root_frobenius β p)]⟩,
  inv_fun := λ f, ⟨f.1 ∘ of α p, @@is_ring_hom.comp _ _ _ _ _ _ f.2⟩,
  left_inv := λ ⟨f, hf⟩, subtype.eq rfl,
  right_inv := λ ⟨f, hf⟩, subtype.eq $ funext $ λ i, quot.induction_on i $ λ ⟨m, x⟩,
    show perfect_field.pth_root p^[m] (f _) = f _,
    by resetI; rw [eq_pth_root, @nat.iterate₁ _ _ _ _ f (λ x:perfect_closure α p, (is_ring_hom.pth_root p f).symm)] }

end perfect_closure
