Require Import List.
Require Import Ring.
Require Import Lia.
Require Import NPeano.

Require Import misc_arith.
Require Import misc_list.

Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Implicit Defensive.

Import ListNotations.
Open Scope list_scope.

(* --------------------------------------------------------------------- *)
(* PIGEONHOLE PRINCIPLE                                                  *)
(* --------------------------------------------------------------------- *)

Section Pigeon.

Variable A: Type.
Variable A_eqdec: forall x y:A, {x=y}+{x<>y}.


Inductive remove (a:A): list A -> list A -> Prop :=
 | remove_nil: remove a nil nil
 | remove_na: forall x xs ys, x <> a -> remove a xs ys -> remove a (x :: xs) (x :: ys)
 | remove_a: forall xs ys, remove a xs ys -> remove a (a :: xs) ys.

Lemma remove_exists:
forall a: A,
forall xs: list A,
exists ys: list A,
remove a xs ys.
Proof.
induction xs.
- exists nil.
  apply remove_nil.
- elim IHxs; intros.
  destruct (A_eqdec a a0) as [HH|HH].
  subst; exists x; constructor 3; assumption.
  exists (a0 :: x).
  apply remove_na.
  + apply not_eq_sym.
    exact HH.
  + exact H.
Qed.

Lemma remove_notin:
forall a: A,
forall xs ys: list A,
~ In a xs ->
remove a xs ys ->
ys = xs.
Proof.
induction xs.
- intros ys H1 H2.
  inversion H2.
  reflexivity.
- intros ys H1 H2.
  inversion H2.
  + subst.
    assert (~ In a xs).
      {
      simpl in H1.
      intros H4.
      apply H1.
      right.
      exact H4.
      }
    specialize (IHxs ys0 H H5).
    subst.
    reflexivity.
  + subst.
    destruct H1.
    simpl.
    left.
    reflexivity.
Qed.

Lemma remove_length_in:
forall a: A,
forall xs ys: list A,
In a xs ->
remove a xs ys ->
length ys < length xs.
Proof.
intros a xs ys H1 H2.
revert H1.
induction H2.
- intros H.
  simpl in H.
  contradiction.
- intros H3.
  simpl in H3.
  destruct H3 as [H3 | H3].
  + subst.
    destruct H.
    reflexivity.
  + specialize (IHremove H3).
    simpl.
    lia.
- intros H3.
  destruct (In_dec A_eqdec a xs) as [H|H].
  + specialize (IHremove H).
    simpl.
    lia.
  + apply remove_notin in H2.
    * subst.
      simpl.
      lia.
    * exact H.
Qed.

Lemma remove_in_notin:
forall a: A,
forall xs ys: list A,
forall e: A,
remove a xs ys ->
In e xs ->
e = a \/ In e ys.
Proof.
intros a xs ys e H.
revert e.
induction H.
- intros e H.
  simpl in H.
  contradiction.
- intros e H1.
  simpl in H1.
  destruct H1 as [H1 | H1].
  + right.
    simpl.
    left.
    exact H1.
  + specialize (IHremove e H1).
    destruct IHremove as [IHremove | IHremove].
    * left.
      exact IHremove.
    * right.
      simpl.
      right.
      exact IHremove.
- intros e H1.
  simpl in H1.
  destruct H1 as [H1 | H1].
  + left.
    symmetry.
    exact H1.
  + specialize (IHremove e H1).
    exact IHremove.
Qed.

Lemma pigeon_aux:
forall x y: list A,
(forall e, In e x -> In e y) ->
(length x > length y) ->
~ NoDup x.
Proof.
intros.
red.
intro.
revert y H H0.
elim H1.
- simpl; intros.
  lia.
- intros.
  simpl in H3.
  generalize (remove_exists x0 y); intros [y' Hy'].
  assert (length y' < length y).
  eapply remove_length_in; auto.
  apply H2 with (y:=y').
  + intros.
    generalize (@remove_in_notin x0 y y').
    intros.
    destruct H7 with e.
    * exact Hy'.
    * apply H3.
      right.
      exact H6.
    * subst.
      destruct H.
      exact H6.
    * exact H8.
  + simpl in H4.
    lia.
Qed.

Lemma nodup_or:
forall a: A,
forall x: list A,
~ NoDup (a :: x) ->
~ NoDup x \/ In a x.
Proof.
intros.
destruct (In_dec A_eqdec a x) as [Hin|Hin]; auto.
left; intro HH.
apply H; constructor; auto.
Qed.

Lemma pigeon:
forall x y: list A,
(forall e: A, In e x -> In e y) ->
length x = length y + 1->
exists d: A,
exists x1 x2 x3: list A,
x = x1 ++ [d] ++ x2 ++ [d] ++ x3.
Proof.
intros x y H1 H2.
apply pigeon_aux in H1.
- clear H2.
  induction x.
  + destruct H1.
    apply NoDup_nil.
  + assert (~ NoDup x \/ In a x).
      {
      apply nodup_or.
      exact H1.
      }
    destruct H as [H | H].
    * specialize (IHx H).
      destruct IHx as [d [x1 [x2 [x3 IHx]]]].
      rewrite IHx.
      exists d, (a :: x1), x2, x3.
      repeat rewrite <- app_assoc.
      reflexivity.
    * apply in_split in H.
      destruct H as [l1 [l2 H]].
      exists a, [], l1, l2.
      rewrite H.
      simpl.
      reflexivity.
- lia.
Qed.

End Pigeon.
