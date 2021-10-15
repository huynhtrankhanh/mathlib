/-
Copyright (c) 2021 Jujian Zhang. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jujian Zhang
-/

import algebra.direct_sum.ring
import ring_theory.ideal.basic
import ring_theory.ideal.operations


/-!

# Homogeneous ideal of a graded commutative ring

This file defines properties of ideals of graded commutative ring `⨁ i, A i`

-/

noncomputable theory

open_locale direct_sum classical
open set direct_sum

variables {ι : Type*} [add_comm_monoid ι] {A : ι → Type*} [Π i, comm_ring (A i)] [gcomm_semiring A]

/-- An element `x : ⨁ i, A i` is a homogeneous element if it is a member of one of the summand. -/
def is_homogeneous_element (x : ⨁ i, A i) : Prop := ∃ i (y : A i), x = of A i y

/-- this might be useful, but I don't know where to put it -/
def graded_monoid.to_direct_sum : (graded_monoid A) →* (⨁ i, A i) :=
{ to_fun := λ a, of A a.fst a.snd,
  map_one' := by norm_cast at *,
  map_mul' := λ x y, begin
    rcases x with ⟨i, x⟩, rcases y with ⟨j, y⟩,
    have eq₁ : (of A (⟨i, x⟩ * ⟨j, y⟩ : graded_monoid A).fst) = of A (i + j) := by congr,
    have eq₂ : (⟨i, x⟩ * ⟨j, y⟩ : graded_monoid A).snd = graded_monoid.ghas_mul.mul x y := rfl,
    rw [eq₁, eq₂, ←mul_hom_of_of], refl,
  end, }

/-- A homogeneous ideal of `⨁ i, A i` is an `I : ideal (⨁ i, A i)` such that `I` is generated by
some set `S` which only consists of homogeneous elements. -/
def homogeneous_ideal (I : ideal (⨁ i, A i)) : Prop :=
   ∃ S, (∀ s ∈ S, is_homogeneous_element s) ∧ I = ideal.span S

/-- Equivalently, an `I : ideal (⨁ i, A i)` is homogeneous iff `I` is spaned by its homogeneous
element-/
def homogeneous_ideal' (I : ideal (⨁ i, A i)) : Prop :=
  I = ideal.span {x ∈ I.carrier | is_homogeneous_element x }

lemma homogeneous_ideal_iff_homogeneous_ideal' (I : ideal (⨁ i, A i)) :
  homogeneous_ideal I ↔ homogeneous_ideal' I :=
⟨λ HI, begin
    rcases HI with ⟨S, HS₁, I_eq_span_S⟩,
    ext, split; intro hx; rw I_eq_span_S at hx,
    { have HS₂ : S ⊆ {x ∈ I.carrier | is_homogeneous_element x},
      { intros y hy, split,
        { suffices : S ⊆ I.carrier, refine this _, exact hy,
          suffices : S ⊆ I, exact this,
          rw ←ideal.span_le, rw I_eq_span_S, exact le_refl _, },
        { dsimp only, apply HS₁ _ hy, } },
      suffices : ideal.span S ≤ ideal.span {x ∈ I.carrier | is_homogeneous_element x},
      refine this _, exact hx,
      exact ideal.span_mono HS₂ },
    { suffices : {x ∈ (ideal.span S).carrier | is_homogeneous_element x} ⊆ I,
      have H : ideal.span {x ∈ (ideal.span S).carrier | is_homogeneous_element x} ≤ ideal.span I,
      { exact ideal.span_mono this },
      rw [ideal.span_eq] at H,
      refine H _, exact hx,

      rintros y ⟨hy₁, hy₂⟩, rw ←I_eq_span_S at hy₁, exact (submodule.mem_carrier I).mp hy₁, }
  end, λ HI, begin
    use {x ∈ I.carrier | is_homogeneous_element x },
    refine ⟨_, HI⟩,
    rintros _ ⟨_, h⟩, exact h
  end⟩

lemma homogeneous_ideal.mul {I J : ideal (⨁ i, A i)}
  (HI : homogeneous_ideal I) (HJ : homogeneous_ideal J) :
  homogeneous_ideal (I * J) :=
begin
  rcases HI with ⟨SI, ⟨SI_hom, I_eq_span_SI⟩⟩,
  rcases HJ with ⟨SJ, ⟨SJ_hom, J_eq_span_SJ⟩⟩,

  use ⋃ (s₁ ∈ SI) (s₂ ∈ SJ), {s₁ * s₂}, split,
  { intros x Hx, simp only [exists_prop, mem_Union, mem_singleton_iff] at Hx ⊢,
    rcases Hx with ⟨s₁, hs₁, s₂, hs₂, hx⟩,
    specialize SI_hom s₁ hs₁,
    specialize SJ_hom s₂ hs₂,
    rcases SI_hom with ⟨i, y₁, hy₁⟩,
    rcases SJ_hom with ⟨j, y₂, hy₂⟩,
    use (i+j), use (graded_monoid.ghas_mul.mul y₁ y₂), rw [hx, hy₁, hy₂, ←mul_hom_of_of], refl, },
  { ext, split,
    { intro hx, rw [←ideal.span_mul_span, ←I_eq_span_SI, ←J_eq_span_SJ], exact hx, },
    { intro hx, rw [←ideal.span_mul_span, ←I_eq_span_SI, ←J_eq_span_SJ] at hx, exact hx, } }
end

lemma homogeneous_ideal.add {I J : ideal (⨁ i, A i)}
  (HI : homogeneous_ideal I) (HJ : homogeneous_ideal J) :
  homogeneous_ideal (I + J) :=
begin
  rcases HI with ⟨SI, ⟨SI_hom, I_eq_span_SI⟩⟩,
  rcases HJ with ⟨SJ, ⟨SJ_hom, J_eq_span_SJ⟩⟩,

  use SI ∪ SJ, split,
  { intros x Hx, simp only [mem_union_eq] at Hx,
    cases Hx, exact SI_hom _ Hx, exact SJ_hom _ Hx, },
  { rw [←ideal.submodule_span_eq, submodule.span_union,
      ideal.submodule_span_eq, ideal.submodule_span_eq, I_eq_span_SI, J_eq_span_SJ], refl, }
end

#lint
