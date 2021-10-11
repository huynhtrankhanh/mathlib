/-
Copyright (c) 2021 Yaël Dillies, Bhavik Mehta. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies, Bhavik Mehta
-/
import .mathlib

/-!
# Constructions of `finpartition_on`
-/

open finset

variables {α : Type*}

def has_subset.subset.finpartition_on [decidable_eq α] {s : finset α}
  {P : finpartition_on s} {A : finset (finset α)} (h : A ⊆ P.parts) :
  finpartition_on (A.bUnion id) :=
{ parts := A,
  disjoint := λ a b ha hb, P.disjoint a b (h ha) (h hb),
  cover := λ x hx, mem_bUnion.1 hx,
  subset := λ a, subset_bUnion_of_mem _,
  not_empty_mem := λ hA, P.not_empty_mem (h hA) }

lemma has_subset.subset.finpartition_on_parts [decidable_eq α] {s : finset α}
  {P : finpartition_on s} {A : finset (finset α)} (h : A ⊆ P.parts) :
  h.finpartition_on.parts = A := rfl

open finpartition_on

section
variables [decidable_eq α] {s : finset α}

lemma equitabilise_aux1 {m a b : ℕ} (hs : a*m + b*(m+1) = s.card) (A : finset (finset α))
  (subs : ∀ i ∈ A, i ⊆ s) (h : s = ∅) :
  ∃ (P : finset (finset α)),
    (∀ (x : finset α), x ∈ P → x.card = m ∨ x.card = m+1) ∧
    (∀ x, x ∈ A → (x \ finset.bUnion (P.filter (λ y, y ⊆ x)) id).card ≤ m) ∧
    (∀ x ∈ s, ∃ y ∈ P, x ∈ y) ∧
    (∀ (x₁ x₂ ∈ P) i, i ∈ x₁ → i ∈ x₂ → x₁ = x₂) ∧
    (∀ x ∈ P, x ⊆ s) ∧
    ((P.filter (λ i, finset.card i = m+1)).card = b) :=
begin
  subst h,
  simp only [finset.subset_empty] at subs,
  simp only [finset.card_empty, nat.mul_eq_zero, nat.succ_ne_zero, or_false,
    add_eq_zero_iff, and_false] at hs,
  refine ⟨∅, by simp, λ i hi, by simp [subs i hi], by simp [hs.2]⟩,
end

lemma equitabilise_aux2 {m a b : ℕ} (hs : a*m + b*(m+1) = s.card) (A : finset (finset α))
  (subs : ∀ i ∈ A, i ⊆ s) (h : m = 0) :
  ∃ (P : finset (finset α)),
    (∀ (x : finset α), x ∈ P → x.card = m ∨ x.card = m+1) ∧
    (∀ x, x ∈ A → (x \ finset.bUnion (P.filter (λ y, y ⊆ x)) id).card ≤ m) ∧
    (∀ x ∈ s, ∃ y ∈ P, x ∈ y) ∧
    (∀ (x₁ x₂ ∈ P) i, i ∈ x₁ → i ∈ x₂ → x₁ = x₂) ∧
    (∀ x ∈ P, x ⊆ s) ∧
    ((P.filter (λ i, finset.card i = m+1)).card = b) :=
begin
  subst h,
  simp only [mul_one, zero_add, mul_zero] at hs,
  simp only [exists_prop, finset.card_eq_zero, zero_add, le_zero_iff, sdiff_eq_empty_iff_subset],
  refine ⟨s.image singleton, by simp, _, by simp, _, by simp, _⟩,
  { intros x hx i hi,
    simp only [mem_bUnion, mem_image, exists_prop, mem_filter, id.def],
    refine ⟨{i}, ⟨⟨i, subs x hx hi, rfl⟩, by simpa⟩, by simp⟩ },
  { simp only [mem_image, and_imp, exists_prop, exists_imp_distrib],
    rintro _ _ x _ rfl y _ rfl,
    simp [singleton_inj] },
  { simp only [mem_image, and_imp, filter_true_of_mem, implies_true_iff, eq_self_iff_true,
      forall_apply_eq_imp_iff₂, exists_imp_distrib, card_singleton],
    rw [card_image_of_injective, hs],
    intros _ _ t,
    rwa singleton_inj at t }
end

lemma equitabilise_aux {m a b : ℕ} (hs : a*m + b*(m+1) = s.card) (A : finset (finset α))
  (all : ∀ x ∈ s, ∃ y ∈ A, x ∈ y)
  (disj : ∀ (x₁ x₂ ∈ A) i, i ∈ x₁ → i ∈ x₂ → x₁ = x₂)
  (subs : ∀ i ∈ A, i ⊆ s) :
  ∃ (P : finset (finset α)),
    (∀ (x : finset α), x ∈ P → x.card = m ∨ x.card = m + 1) ∧
    (∀ x, x ∈ A → (x \ finset.bUnion (P.filter (λ y, y ⊆ x)) id).card ≤ m) ∧
    (∀ x ∈ s, ∃ y ∈ P, x ∈ y) ∧
    (∀ (x₁ x₂ ∈ P) i, i ∈ x₁ → i ∈ x₂ → x₁ = x₂) ∧
    (∀ x ∈ P, x ⊆ s) ∧
    ((P.filter (λ i, finset.card i = m+1)).card = b) :=
begin
  induction s using finset.strong_induction with s ih generalizing A a b,
  cases s.eq_empty_or_nonempty with h hs_ne,
  { exact equitabilise_aux1 hs A subs h },
  cases (nat.eq_zero_or_pos m) with h m_pos,
  { exact equitabilise_aux2 hs A subs h },
  have : 0 < a ∨ 0 < b,
  { by_contra,
    push_neg at h,
    simp only [le_zero_iff] at h,
    rw [h.1, h.2] at hs,
    simp only [add_zero, zero_mul, eq_comm, finset.card_eq_zero] at hs,
    exact hs_ne.ne_empty hs },
  set p'_size := if 0 < a then m else m+1 with h',
  have : 0 < p'_size,
  { rw h',
    split_ifs,
    { apply m_pos },
    exact nat.succ_pos' },
  by_cases ∃ p ∈ A, m+1 ≤ finset.card p,
  { rcases h with ⟨p, hp₁, hp₂⟩,
    have : p'_size ≤ p.card,
    { apply le_trans _ hp₂,
      rw h',
      split_ifs,
      { apply nat.le_succ },
      refl },
    obtain ⟨p', hp'₁, hp'₂⟩ := exists_smaller_set _ _ this,
    have : p'.nonempty,
    { rwa [←card_pos, hp'₂] },
    obtain ⟨P', hP'₁, hP'₂, hP'₃, hP'₄, hP'₅, hP'₆⟩ :=
      @ih (s \ p')
      (sdiff_ssubset (finset.subset.trans hp'₁ (subs _ hp₁)) ‹p'.nonempty›)
      (insert (p \ p') (A.erase p))
      (if 0 < a then a-1 else a)
      (if 0 < a then b else b-1)
      _ _ _ _,
    rotate,
    { rw [card_sdiff (finset.subset.trans hp'₁ (subs _ hp₁)), ←hs, hp'₂, h'],
      split_ifs,
      { rw [nat.mul_sub_right_distrib, one_mul,
          nat.sub_add_eq_add_sub (nat.le_mul_of_pos_left h)] },
      { rw [nat.mul_sub_right_distrib, one_mul, ←nat.add_sub_assoc],
        apply nat.le_mul_of_pos_left (‹0 < a ∨ 0 < b›.resolve_left h) } },
    { simp only [and_imp, exists_prop, mem_insert, mem_sdiff, mem_erase, ne.def],
      intros x hx₁ hx₂,
      by_cases x ∈ p,
      { refine ⟨p \ p', or.inl rfl, by simp only [hx₂, h, mem_sdiff, not_false_iff, and_self]⟩ },
    obtain ⟨y, hy₁, hy₂⟩ := all x hx₁,
      refine ⟨y, or.inr ⟨λ t, _, hy₁⟩, hy₂⟩,
      apply h,
      rw ←t,
      exact hy₂ },
    { simp only [mem_insert, mem_erase, ne.def],
      rintro x₁ x₂ (rfl | hx₁) (rfl | hx₂) i hi₁ hi₂,
      { refl },
      { apply (hx₂.1 (disj _ _ hx₂.2 hp₁ i hi₂ (sdiff_subset _ _ hi₁))).elim },
      { apply (hx₁.1 (disj _ _ hx₁.2 hp₁ i hi₁ (sdiff_subset _ _ hi₂))).elim },
      exact disj _ _ hx₁.2 hx₂.2 _ hi₁ hi₂ },
    { simp only [and_imp, mem_insert, forall_eq_or_imp, mem_erase, ne.def],
      split,
      { apply sdiff_subset_sdiff (subs _ hp₁) (refl _) },
      intros i hi₁ hi₂ x hx,
      simp only [mem_sdiff, subs i hi₂ hx, true_and],
      exact λ q, hi₁ (disj _ _ hi₂ hp₁ _ hx (hp'₁ q)) },
    refine ⟨insert p' P', _, _, _, _, _, _⟩,
    { simp only [mem_insert, forall_eq_or_imp, and_iff_left hP'₁, hp'₂, h'],
      split_ifs,
      { left, refl },
      { right, refl } },
    { conv in (_ ∈ _) {rw ←finset.insert_erase hp₁},
      simp only [and_imp, mem_insert, forall_eq_or_imp, ne.def],
      split,
      { simp only [filter_insert, if_pos hp'₁, bUnion_insert, mem_erase],
        apply le_trans (card_le_of_subset _) (hP'₂ (p \ p') (mem_insert_self _ _)),
        intros i,
        simp only [not_exists, mem_bUnion, and_imp, mem_union, mem_filter, mem_sdiff, id.def,
          not_or_distrib],
        intros hi₁ hi₂ hi₃,
        refine ⟨⟨hi₁, hi₂⟩, λ x hx hx', hi₃ _ hx (finset.subset.trans hx' (sdiff_subset _ _))⟩ },
      intros x hx,
      apply (card_le_of_subset _).trans (hP'₂ x (mem_insert_of_mem hx)),
      apply sdiff_subset_sdiff (finset.subset.refl _) (bUnion_subset_bUnion_of_subset_left _ _),
      refine filter_subset_filter _ (subset_insert _ _) },
    { simp only [and_imp, exists_prop, mem_sdiff] at hP'₃,
      simp only [exists_prop, mem_insert, or_and_distrib_right, exists_or_distrib],
      intros x hx,
      refine if h : x ∈ p' then or.inl ⟨_, rfl, h⟩ else or.inr (hP'₃ _ hx h) },
    { simp only [mem_insert, forall_eq_or_imp],
      rintro x₁ x₂ (rfl | hx₁) (rfl | hx₂),
      { simp },
      { intros i hi₁ hi₂,
        apply ((mem_sdiff.1 (hP'₅ _ hx₂ hi₂)).2 hi₁).elim },
      { intros i hi₁ hi₂,
        apply ((mem_sdiff.1 (hP'₅ _ hx₁ hi₁)).2 hi₂).elim },
      exact hP'₄ _ _ hx₁ hx₂ },
    { simp only [mem_insert, forall_eq_or_imp],
      refine ⟨finset.subset.trans hp'₁ (subs _ hp₁),
        λ x hx i hi, (mem_sdiff.1 (hP'₅ x hx hi)).1⟩ },
    rw [filter_insert, hp'₂, h'],
    by_cases 0 < a,
    { rw [if_pos h, if_neg, hP'₆, if_pos h],
      simp only [nat.one_ne_zero, self_eq_add_right, not_false_iff] },
    rw [if_neg h, if_pos rfl, card_insert_of_not_mem, hP'₆, if_neg h, nat.sub_add_cancel],
    apply ‹0 < a ∨ 0 < b›.resolve_left h,
    simp only [mem_filter, hp'₂, h', if_neg h, eq_self_iff_true, and_true],
    intro t,
    obtain ⟨i, hi⟩ := ‹p'.nonempty›,
    apply (mem_sdiff.1 (hP'₅ _ t hi)).2 hi },
  push_neg at h,
  have : p'_size ≤ s.card,
  { rw [←hs, h'],
    split_ifs,
    { apply le_add_right (nat.le_mul_of_pos_left ‹0 < a›) },
    exact le_add_left (nat.le_mul_of_pos_left (‹0 < a ∨ 0 < b›.resolve_left ‹¬0 < a›)) },
  obtain ⟨s', hs'₁, hs'₂⟩ := exists_smaller_set _ _ this,
  have : s'.nonempty,
  { rwa [←card_pos, hs'₂] },
  obtain ⟨P', hP'₁, hP'₂, hP'₃, hP'₄, hP'₅, hP'₆⟩ :=
    @ih (s \ s')
    (sdiff_ssubset hs'₁ ‹s'.nonempty›)
    (A.image (λ t, t \ s'))
    (if 0 < a then a-1 else a)
    (if 0 < a then b else b-1)
    _ _ _ _,
  rotate,
  { rw [card_sdiff ‹s' ⊆ s›, hs'₂, h', ←hs],
    split_ifs,
    { rw [nat.mul_sub_right_distrib, one_mul,
        nat.sub_add_eq_add_sub (nat.le_mul_of_pos_left ‹0 < a›)] },
    rw [nat.mul_sub_right_distrib, one_mul, ←nat.add_sub_assoc],
    exact nat.le_mul_of_pos_left (‹0 < a ∨ 0 < b›.resolve_left ‹¬0 < a›) },
  { intros x hx,
    simp only [mem_sdiff] at hx,
    obtain ⟨y, hy, hy'⟩ := all x hx.1,
    simp only [mem_image, exists_prop, mem_sdiff, exists_exists_and_eq_and],
    refine ⟨_, hy, hy', hx.2⟩ },
  { simp only [mem_image, and_imp, exists_prop, exists_imp_distrib],
    rintro x₁ x₂ x hx rfl x' hx' rfl i hi₁ hi₂,
    simp only [mem_sdiff] at hi₁ hi₂,
    rw disj _ _ hx hx' i hi₁.1 hi₂.1 },
  { simp only [mem_image, and_imp, forall_apply_eq_imp_iff₂, exists_imp_distrib],
    intros a ha,
    apply sdiff_subset_sdiff (subs a ha) (refl _) },
  refine ⟨insert s' P', _, _, _, _, _, _⟩,
  { simp only [mem_insert, forall_eq_or_imp, and_iff_left hP'₁, hs'₂, h'],
    split_ifs,
    { left, refl },
    right, refl },
  { intros x hx,
    refine le_trans (card_le_of_subset (sdiff_subset _ _)) _,
    rw ←nat.lt_succ_iff,
    exact h _ hx },
  { intros x hx,
    by_cases x ∈ s',
    { refine ⟨_, by simp only [mem_insert, true_or, eq_self_iff_true], h⟩ },
    obtain ⟨w, hw, hw'⟩ := hP'₃ x (by simp only [hx, h, mem_sdiff, not_false_iff, and_self]),
    exact ⟨w, by simp only [hw, mem_insert, or_true], hw'⟩ },
  { simp only [mem_insert],
    rintro _ _ (rfl | hx₁) (rfl | hx₂) i hi₁ hi₂,
    { refl },
    { apply ((mem_sdiff.1 (hP'₅ _ hx₂ hi₂)).2 hi₁).elim },
    { apply ((mem_sdiff.1 (hP'₅ _ hx₁ hi₁)).2 hi₂).elim },
    exact hP'₄ _ _ hx₁ hx₂ _ hi₁ hi₂ },
  { simp only [hs'₁, true_and, mem_insert, forall_eq_or_imp],
    intros x hx,
    apply finset.subset.trans (hP'₅ x hx) (sdiff_subset _ _) },
  rw [filter_insert, hs'₂, h'],
  by_cases 0 < a,
  { rw [if_pos h, if_neg, hP'₆, if_pos h],
    simp only [nat.one_ne_zero, self_eq_add_right, not_false_iff] },
  rw [if_neg h, if_pos rfl, card_insert_of_not_mem, hP'₆, if_neg h, nat.sub_add_cancel],
  apply ‹0 < a ∨ 0 < b›.resolve_left h,
  simp only [mem_filter, hs'₂, h', if_neg h, eq_self_iff_true, and_true],
  intro t,
  obtain ⟨i, hi⟩ := ‹s'.nonempty›,
  exact (mem_sdiff.1 (hP'₅ _ t hi)).2 hi,
end.

/-! ### Equitabilise -/

namespace finpartition_on

/-- Given a partition `Q` of `s`, as well as a proof that `a*m + b*(m+1) = s.card`, build a new
partition `P` of `s` where each part has size `m` or `m+1`, every part of `Q` is the union of
parts of `P` plus at most `m` extra elements, there are `b` parts of size `m+1` and provided
`m > 0`, there are `a` parts of size `m` and hence `a+b` parts in total.
The `m > 0` condition is required since there may be zero or one parts of size `0`, while `a` could
be arbitrary. -/
noncomputable def equitabilise (Q : finpartition_on s) {m a b : ℕ}
  (h : a*m + b*(m+1) = s.card) :
  finpartition_on s :=
begin
  let P := classical.some (equitabilise_aux h Q.parts Q.cover Q.disjoint Q.subset),
  have hP := classical.some_spec (equitabilise_aux h Q.parts Q.cover Q.disjoint Q.subset),
  refine ⟨P.erase ∅,
    λ a b ha hb x hxa hxb, hP.2.2.2.1 a b (erase_subset _ _ ha) (erase_subset _ _ hb) x hxa hxb,
    λ u hu, _, λ u hu, hP.2.2.2.2.1 _ (erase_subset _ _ hu), not_mem_erase _ _⟩,
  obtain ⟨a, ha, hua⟩ := hP.2.2.1 u hu,
  exact ⟨a, mem_erase.2 ⟨nonempty_iff_ne_empty.1 ⟨u, hua⟩, ha⟩, hua⟩,
end

lemma card_eq_of_mem_parts_equitabilise {Q : finpartition_on s} {m a b : ℕ}
  (h : a*m + b*(m+1) = s.card) {u : finset α} (hu : u ∈ (Q.equitabilise h).parts) :
  u.card = m ∨ u.card = m + 1 :=
(classical.some_spec (equitabilise_aux h Q.parts Q.cover Q.disjoint Q.subset)).1
  u (mem_of_mem_erase hu)

lemma equitabilise.is_equipartition (Q : finpartition_on s) {m a b : ℕ}
  (h : a*m + b*(m+1) = s.card) :
  (Q.equitabilise h).is_equipartition :=
begin
  rw [finpartition_on.is_equipartition, set.equitable_on_iff_exists_eq_eq_add_one],
  exact ⟨m, λ u hu, card_eq_of_mem_parts_equitabilise h hu⟩,
end

lemma card_filter_equitabilise_big (Q : finpartition_on s) {m a b : ℕ}
  (h : a*m + b*(m+1) = s.card) :
  ((Q.equitabilise h).parts.filter (λ u : finset α, u.card = m + 1)).card = b :=
begin
  convert (classical.some_spec (equitabilise_aux h Q.parts Q.cover Q.disjoint
    Q.subset)).2.2.2.2.2 using 2,
  ext u,
  rw [mem_filter, mem_filter, finpartition_on.equitabilise, mem_erase, and_assoc,
    and_iff_right_iff_imp],
  rintro hu rfl,
  rw finset.card_empty at hu,
  exact nat.succ_ne_zero _ hu.2.symm,
end

lemma card_filter_equitabilise_small (Q : finpartition_on s) {m a b : ℕ} (hm : 0 < m)
  (h : a*m + b*(m+1) = s.card) :
  ((Q.equitabilise h).parts.filter (λ u : finset α, u.card = m)).card = a :=
begin
  refine (mul_eq_mul_right_iff.1 $ (add_left_inj $ b * (m + 1)).1 _).resolve_right hm.ne',
  rw [h, ←(Q.equitabilise h).sum_card_parts],
  have hunion : (Q.equitabilise h).parts = (Q.equitabilise h).parts.filter (λ u, u.card = m) ∪
    (Q.equitabilise h).parts.filter (λ u, u.card = m + 1),
  { rw [←filter_or, filter_true_of_mem],
    exact λ x hx, card_eq_of_mem_parts_equitabilise h hx },
  nth_rewrite 1 hunion,
  rw [sum_union, sum_const_nat (λ x hx, (mem_filter.1 hx).2),
    sum_const_nat (λ x hx, (mem_filter.1 hx).2), Q.card_filter_equitabilise_big],
  refine λ x hx, nat.succ_ne_self m _,
  rw [inf_eq_inter, mem_inter, mem_filter, mem_filter] at hx,
  rw [nat.succ_eq_add_one, ←hx.2.2, hx.1.2],
end

lemma equitabilise.size {Q : finpartition_on s} {m a b : ℕ} (hm : 0 < m)
  (h : a * m + b * (m + 1) = s.card) :
  (Q.equitabilise h).size = a + b :=
begin
  have hunion : (Q.equitabilise h).parts = (Q.equitabilise h).parts.filter (λ u, u.card = m) ∪
    (Q.equitabilise h).parts.filter (λ u, u.card = m + 1),
  { rw [←filter_or, filter_true_of_mem],
    exact λ x hx, card_eq_of_mem_parts_equitabilise h hx },
  rw [finpartition_on.size, hunion, card_union_eq, Q.card_filter_equitabilise_small hm,
    Q.card_filter_equitabilise_big],
  refine λ x hx, nat.succ_ne_self m _,
  rw [inf_eq_inter, mem_inter, mem_filter, mem_filter] at hx,
  rw [nat.succ_eq_add_one, ←hx.2.2, hx.1.2],
end

lemma almost_in_atoms_of_mem_parts_equitabilise {Q : finpartition_on s} {m a b : ℕ}
  (h : a * m + b * (m + 1) = s.card) {u : finset α} (hu : u ∈ Q.parts) :
  (u \ ((Q.equitabilise h).parts.filter $ λ x, x ⊆ u).bUnion id).card ≤ m :=
begin
  have := (classical.some_spec (equitabilise_aux h Q.parts Q.cover Q.disjoint
    Q.subset)).2.1,
  refine (card_le_of_subset _).trans ((classical.some_spec (equitabilise_aux h Q.parts Q.cover
    Q.disjoint Q.subset)).2.1 u hu),
  intros x,
  simp only [not_exists, mem_bUnion, and_imp, mem_filter, mem_sdiff, id.def, ne.def],
  refine λ hxu hx, ⟨hxu, λ a ha hau, _⟩,
  obtain rfl | hanemp := eq_or_ne a ∅,
  { exact not_mem_empty _ },
  exact hx _ (mem_erase.2 ⟨hanemp, ha⟩) hau,
end

end finpartition_on

end

/-! ### Atomise -/

section atomise
variables [decidable_eq α] {s : finset α}

/-- Cuts `s` along the finsets in `Q`: Two elements of `s` will be in the same part if they are
in the same finsets of `Q`. -/
def atomise (s : finset α) (Q : finset (finset α)) :
  finpartition_on s :=
{ parts := Q.powerset.image (λ P, s.filter (λ i, ∀ x ∈ Q, x ∈ P ↔ i ∈ x)) \ {∅},
  disjoint := begin
    rintro x y hx hy i hi₁ hi₂,
    simp only [mem_sdiff, mem_powerset, mem_image, exists_prop] at hx hy,
    obtain ⟨P, hP, rfl⟩ := hx.1,
    obtain ⟨P', hP', rfl⟩ := hy.1,
    suffices h : P = P',
    { subst h },
    rw mem_filter at hi₁ hi₂,
    ext j,
    refine ⟨λ hj, _, λ hj, _⟩,
    { rwa [hi₂.2 _ (hP hj), ←hi₁.2 _ (hP hj)] },
    rwa [hi₁.2 _ (hP' hj), ←hi₂.2 _ (hP' hj)],
  end,
  cover := begin
    rintro x hx,
    simp only [mem_sdiff, mem_powerset, mem_image, exists_prop, mem_filter, and_assoc],
    rw exists_exists_and_eq_and,
    have h : x ∈ s.filter (λ i, ∀ y ∈ Q, (y ∈ Q.filter (λ t, x ∈ t) ↔ i ∈ y)),
    { simp only [mem_filter, and_iff_right_iff_imp],
      exact ⟨hx, λ y hy _, hy⟩ },
    refine ⟨Q.filter (λ t, x ∈ t), filter_subset _ _, _, h⟩,
    rw [mem_singleton, ←ne.def, ←nonempty_iff_ne_empty],
    exact ⟨x, h⟩,
  end,
  subset := begin
    rintro x hx,
    simp only [mem_sdiff, mem_powerset, mem_image, exists_prop] at hx,
    obtain ⟨P, hP, rfl⟩ := hx.1,
    exact filter_subset _ s,
  end,
  not_empty_mem := λ h, (mem_sdiff.1 h).2 (mem_singleton_self _) }

lemma mem_atomise {s : finset α} {Q : finset (finset α)} {A : finset α} :
  A ∈ (atomise s Q).parts ↔ A.nonempty ∧ ∃ (P ⊆ Q), s.filter (λ i, ∀ x ∈ Q, x ∈ P ↔ i ∈ x) = A :=
by { simp only [atomise, mem_sdiff, nonempty_iff_ne_empty, mem_singleton, and_comm, mem_image,
  mem_powerset, exists_prop] }

lemma atomise_empty (hs : s.nonempty) : (atomise s ∅).parts = {s} :=
begin
  rw [atomise],
  simp,
  apply disjoint.sdiff_eq_left,
  rwa [disjoint_singleton, mem_singleton, ←ne.def, ne_comm, ←nonempty_iff_ne_empty],
end

lemma atomise_disjoint {s : finset α} {Q : finset (finset α)} {x y : finset α}
  (hx : x ∈ (atomise s Q).parts) (hy : y ∈ (atomise s Q).parts) : disjoint x y ∨ x = y :=
begin
  rw or_iff_not_imp_left,
  simp only [disjoint_left, not_forall, and_imp, exists_prop, not_not, exists_imp_distrib],
  intros i hi₁ hi₂,
  simp only [mem_atomise] at hx hy,
  obtain ⟨P, hP, rfl⟩ := hx.2,
  obtain ⟨P', hP', rfl⟩ := hy.2,
  simp only [mem_filter] at hi₁ hi₂,
  suffices h : P = P',
  { subst h },
  ext j,
  refine ⟨λ hj, _, λ hj, _⟩,
  { rwa [hi₂.2 _ (hP hj), ←hi₁.2 _ (hP hj)] },
  { rwa [hi₁.2 _ (hP' hj), ←hi₂.2 _ (hP' hj)] },
end

lemma atomise_covers {s : finset α} (Q : finset (finset α)) {x : α} (hx : x ∈ s) :
  ∃ Y ∈ (atomise s Q).parts, x ∈ Y :=
(atomise s Q).cover hx

lemma atomise_unique_covers {s : finset α} {Q : finset (finset α)} {x : α} (hx : x ∈ s) :
  ∃! Y ∈ (atomise s Q).parts, x ∈ Y :=
begin
  obtain ⟨Y, hY₁, hY₂⟩ := atomise_covers Q hx,
  refine exists_unique.intro2 Y hY₁ hY₂ (λ Y' hY'₁ hY'₂,
    or.resolve_left (atomise_disjoint ‹Y' ∈ _› ‹Y ∈ _›) _),
  simp only [disjoint_left, exists_prop, not_not, not_forall],
  exact ⟨_, hY'₂, hY₂⟩,
end

lemma card_atomise_le {s : finset α} {Q : finset (finset α)} :
  ((atomise s Q).parts).card ≤ 2^Q.card :=
begin
  apply (card_le_of_subset (sdiff_subset _ _)).trans,
  apply finset.card_image_le.trans,
  simp,
end

lemma union_of_atoms_aux {s : finset α} {Q : finset (finset α)} {A : finset α}
  (hA : A ∈ Q) (hs : A ⊆ s) (i : α) :
  (∃ (B ∈ (atomise s Q).parts), B ⊆ A ∧ i ∈ B) ↔ i ∈ A :=
begin
  split,
  { rintro ⟨B, hB₁, hB₂, hB₃⟩,
    exact hB₂ hB₃ },
  intro hi,
  obtain ⟨B, hB₁, hB₂⟩ := atomise_covers Q (hs hi),
  refine ⟨B, hB₁, λ j hj, _, hB₂⟩,
  obtain ⟨P, hP, rfl⟩ := (mem_atomise.1 hB₁).2,
  simp only [mem_filter] at hB₂ hj,
  rwa [←hj.2 _ hA, hB₂.2 _ hA]
end

lemma union_of_atoms {s : finset α} {Q : finset (finset α)} {A : finset α}
  (hA : A ∈ Q) (hs : A ⊆ s) :
  s.filter (λ i, ∃ B ∈ (atomise s Q).parts, B ⊆ A ∧ i ∈ B) = A :=
begin
  ext i,
  simp only [mem_filter, union_of_atoms_aux hA hs],
  exact and_iff_right_iff_imp.2 (@hs i),
end

instance {B : finset α} : decidable B.nonempty :=
decidable_of_iff' _ finset.nonempty_iff_ne_empty

lemma union_of_atoms' {s : finset α} {Q : finset (finset α)} (A : finset α)
  (hx : A ∈ Q) (hs : A ⊆ s) :
  ((atomise s Q).parts.filter (λ B, B ⊆ A ∧ B.nonempty)).bUnion id = A :=
begin
  ext x,
  rw mem_bUnion,
  simp only [exists_prop, mem_filter, id.def, and_assoc],
  rw ←union_of_atoms_aux hx hs,
  simp only [exists_prop],
  exact exists_congr (λ a, and_congr_right (λ b, and_congr_right (λ c,
    and_iff_right_of_imp (λ h, ⟨_, h⟩)))),
end

lemma partial_atomise {s : finset α} {Q : finset (finset α)} (A : finset α)
  (hA : A ∈ Q) (hs : A ⊆ s) :
  ((atomise s Q).parts.filter (λ B, B ⊆ A ∧ B.nonempty)).card ≤ 2^(Q.card - 1) :=
begin
  suffices h :
    (atomise s Q).parts.filter (λ B, B ⊆ A ∧ B.nonempty) ⊆
      (Q.erase A).powerset.image (λ P, s.filter (λ i, ∀ x ∈ Q, x ∈ insert A P ↔ i ∈ x)),
  { apply (card_le_of_subset h).trans (card_image_le.trans _),
    rw [card_powerset, card_erase_of_mem hA],
    refl },
  rw subset_iff,
  simp only [mem_erase, mem_sdiff, mem_powerset, mem_image, exists_prop, mem_filter, and_assoc,
    finset.nonempty, exists_imp_distrib, and_imp, mem_atomise, forall_apply_eq_imp_iff₂],
  rintro P' i hi P PQ rfl hy₂ j hj,
  refine ⟨P.erase A, erase_subset_erase _ PQ, _⟩,
  have : A ∈ P,
  { rw mem_filter at hi,
    rw hi.2 _ hA,
    apply hy₂,
    exact mem_filter.2 hi },
  simp only [insert_erase this, filter_congr_decidable],
end

end atomise

/-! ### Dummy -/

/-- Arbitrary equipartition into `t` parts -/
lemma dummy_equipartition [decidable_eq α] (s : finset α) {t : ℕ}
  (ht : 0 < t) (hs : t ≤ s.card) :
  ∃ (P : finpartition_on s), P.is_equipartition ∧ P.size = t :=
begin
  have : (t - s.card % t) * (s.card / t) + (s.card % t) * (s.card / t + 1) = s.card,
  { rw [nat.mul_sub_right_distrib, mul_add, ←add_assoc, nat.sub_add_cancel, mul_one, add_comm,
      nat.mod_add_div],
    exact nat.mul_le_mul_right _ ((nat.mod_lt _ ht).le) },
  refine ⟨(indiscrete_finpartition_on $ finset.card_pos.1 (ht.trans_le hs)).equitabilise this,
    finpartition_on.equitabilise.is_equipartition _ _, _⟩,
  rw [finpartition_on.equitabilise.size (nat.div_pos hs ht), nat.sub_add_cancel
    (nat.mod_lt _ ht).le],
end
