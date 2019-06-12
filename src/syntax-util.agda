module syntax-util where

open import lib
open import cedille-types
open import general-util
open import constants
--open import type-util

posinfo-gen : posinfo
posinfo-gen = "generated"

pi-gen = posinfo-gen

first-position : posinfo
first-position = "1"

dummy-var : var
dummy-var = "_dummy"

id-term : term
id-term = Lam ff "x" nothing (Var "x")

compileFailType : type
compileFailType = TpAbs tt "X" (Tkk KdStar) (TpVar "X")

qualif-info : Set
qualif-info = var × args

qualif : Set
qualif = trie qualif-info

posinfo-to-ℕ : posinfo → ℕ
posinfo-to-ℕ pi with string-to-ℕ pi
posinfo-to-ℕ pi | just n = n
posinfo-to-ℕ pi | nothing = 0 -- should not happen

posinfo-plus : posinfo → ℕ → posinfo
posinfo-plus pi n = ℕ-to-string (posinfo-to-ℕ pi + n)

posinfo-plus-str : posinfo → string → posinfo
posinfo-plus-str pi s = posinfo-plus pi (string-length s)

-- qualify variable by module name
_#_ : string → string → string
fn # v = fn ^ qual-global-str ^  v

_%_ : posinfo → var → string
pi % v = pi ^ qual-local-str ^ v

compileFail : var
compileFail = "compileFail"
compileFail-qual = "" % compileFail

tk-is-type : tpkd → 𝔹
tk-is-type = either-else (const tt) (const ff)

tT-is-term : tmtp → 𝔹
tT-is-term = either-else (const tt) (const ff)

tk-start-pos : ex-tk → posinfo
term-start-pos : ex-tm → posinfo
type-start-pos : ex-tp → posinfo
kind-start-pos : ex-kd → posinfo

term-start-pos (ExApp t x t₁) = term-start-pos t
term-start-pos (ExAppTp t tp) = term-start-pos t
term-start-pos (ExHole pi) = pi
term-start-pos (ExLam pi x _ x₁ x₂ t) = pi
term-start-pos (ExLet pi _ _ _) = pi
term-start-pos (ExOpen pi _ _ _ _) = pi
term-start-pos (ExParens pi t pi') = pi
term-start-pos (ExVar pi x₁) = pi
term-start-pos (ExBeta pi _ _) = pi
term-start-pos (ExIotaPair pi _ _ _ _) = pi
term-start-pos (ExIotaProj t _ _) = term-start-pos t
term-start-pos (ExEpsilon pi _ _ _) = pi
term-start-pos (ExPhi pi _ _ _ _) = pi
term-start-pos (ExRho pi _ _ _ _ _) = pi
term-start-pos (ExChi pi _ _) = pi
term-start-pos (ExDelta pi _ _) = pi
term-start-pos (ExSigma pi _) = pi
term-start-pos (ExTheta pi _ _ _) = pi
term-start-pos (ExMu pi _ _ _ _ _ _) = pi

type-start-pos (ExTpAbs pi _ _ _ _ _) = pi
type-start-pos (ExTpLam pi _ _ _ _) = pi
type-start-pos (ExTpIota pi _ _ _ _) = pi
type-start-pos (ExTpApp t t₁) = type-start-pos t
type-start-pos (ExTpAppt t x) = type-start-pos t
type-start-pos (ExTpArrow t _ t₁) = type-start-pos t
type-start-pos (ExTpEq pi _ _ pi') = pi
type-start-pos (ExTpParens pi _ pi') = pi
type-start-pos (ExTpVar pi x₁) = pi
type-start-pos (ExTpNoSpans t _) = type-start-pos t -- we are not expecting this on input
type-start-pos (ExTpHole pi) = pi --ACG
type-start-pos (ExTpLet pi _ _) = pi

kind-start-pos (ExKdArrow atk k₁) = tk-start-pos atk
kind-start-pos (ExKdParens pi k pi') = pi
kind-start-pos (ExKdAbs pi _ x x₁ k) = pi
kind-start-pos (ExKdVar pi x₁ _) = pi
kind-start-pos (ExKdStar pi) = pi

tk-start-pos (ExTkt t) = type-start-pos t
tk-start-pos (ExTkk k) = kind-start-pos k

term-end-pos : ex-tm → posinfo
type-end-pos : ex-tp → posinfo
kind-end-pos : ex-kd → posinfo
tk-end-pos : ex-tk → posinfo
lterms-end-pos : posinfo → 𝕃 lterm → posinfo
args-end-pos : posinfo → ex-args → posinfo
arg-end-pos : ex-arg → posinfo
kvar-end-pos : posinfo → var → ex-args → posinfo
params-end-pos : posinfo → ex-params → posinfo
param-end-pos : ex-param → posinfo

term-end-pos (ExApp t x t') = term-end-pos t'
term-end-pos (ExAppTp t tp) = type-end-pos tp
term-end-pos (ExHole pi) = posinfo-plus pi 1
term-end-pos (ExLam pi x _ x₁ x₂ t) = term-end-pos t
term-end-pos (ExLet _ _ _ t) = term-end-pos t
term-end-pos (ExOpen pi _ _ _ t) = term-end-pos t
term-end-pos (ExParens pi t pi') = pi'
term-end-pos (ExVar pi x) = posinfo-plus-str pi x
term-end-pos (ExBeta pi _ (just (PosTm t pi'))) = pi'
term-end-pos (ExBeta pi (just (PosTm t pi')) nothing) = pi'
term-end-pos (ExBeta pi nothing nothing) = posinfo-plus pi 1
term-end-pos (ExIotaPair _ _ _ _ pi) = pi
term-end-pos (ExIotaProj _ _ pi) = pi
term-end-pos (ExEpsilon pi _ _ t) = term-end-pos t
term-end-pos (ExPhi _ _ _ _ pi) = pi
term-end-pos (ExRho pi _ _ _ t t') = term-end-pos t'
term-end-pos (ExChi pi T t') = term-end-pos t'
term-end-pos (ExDelta pi oT t) = term-end-pos t
term-end-pos (ExSigma pi t) = term-end-pos t
term-end-pos (ExTheta _ _ t ls) = lterms-end-pos (term-end-pos t) ls
term-end-pos (ExMu _ _ _ _ _ _ pi) = pi

type-end-pos (ExTpAbs pi _ _ _ _ t) = type-end-pos t
type-end-pos (ExTpLam _ _ _ _ t) = type-end-pos t
type-end-pos (ExTpIota _ _ _ _ tp) = type-end-pos tp
type-end-pos (ExTpApp t t') = type-end-pos t'
type-end-pos (ExTpAppt t x) = term-end-pos x
type-end-pos (ExTpArrow t _ t') = type-end-pos t'
type-end-pos (ExTpEq pi _ _ pi') = pi'
type-end-pos (ExTpParens pi _ pi') = pi'
type-end-pos (ExTpVar pi x) = posinfo-plus-str pi x
type-end-pos (ExTpHole pi) = posinfo-plus pi 1
type-end-pos (ExTpNoSpans t pi) = pi
type-end-pos (ExTpLet _ _ t) = type-end-pos t

kind-end-pos (ExKdArrow atk k) = kind-end-pos k
kind-end-pos (ExKdParens pi k pi') = pi'
kind-end-pos (ExKdAbs pi _ x x₁ k) = kind-end-pos k
kind-end-pos (ExKdVar pi x ys) = args-end-pos (posinfo-plus-str pi x) ys
kind-end-pos (ExKdStar pi) = posinfo-plus pi 1

tk-end-pos (ExTkt T) = type-end-pos T
tk-end-pos (ExTkk k) = kind-end-pos k

args-end-pos pi (x :: ys) = args-end-pos (arg-end-pos x) ys
args-end-pos pi [] = pi

arg-end-pos (ExTmArg me t) = term-end-pos t
arg-end-pos (ExTpArg T) = type-end-pos T

kvar-end-pos pi v = args-end-pos (posinfo-plus-str pi v)

params-end-pos pi [] = pi
params-end-pos pi (p :: ps) = params-end-pos (param-end-pos p) ps

param-end-pos (ExParam pi me pi' x atk pi'') = pi''


lterms-end-pos pi [] = posinfo-plus pi 1 -- must add one for the implicit Beta that we will add at the end
lterms-end-pos pi ((Lterm _ t) :: ls) = lterms-end-pos (term-end-pos t) ls

{- return the end position of the given term if it is there, otherwise
   the given posinfo -}
optTerm-end-pos : posinfo → maybe pos-tm → posinfo
optTerm-end-pos pi nothing = pi
optTerm-end-pos pi (just (PosTm x x₁)) = x₁

optTerm-end-pos-beta : posinfo → maybe pos-tm → maybe pos-tm → posinfo
optTerm-end-pos-beta pi _ (just (PosTm x pi')) = pi'
optTerm-end-pos-beta pi (just (PosTm x pi')) nothing = pi'
optTerm-end-pos-beta pi nothing nothing = posinfo-plus pi 1

optAs-or : maybe import-as → posinfo → var → posinfo × var
optAs-or nothing pi x = pi , x
optAs-or (just (ImportAs pi x)) _ _ = pi , x

TpApp-tk : type → var → tpkd → type
TpApp-tk tp x (Tkk _) = TpApp tp (Ttp (TpVar x))
TpApp-tk tp x (Tkt _) = TpApp tp (Ttm (Var x))

-- checking-sythesizing enum
data checking-mode : Set where
  checking : checking-mode
  synthesizing : checking-mode
  untyped : checking-mode

maybe-to-checking : {A : Set} → maybe A → checking-mode
maybe-to-checking (just _) = checking
maybe-to-checking nothing = synthesizing

eq-checking-mode : (m₁ m₂ : checking-mode) → 𝔹
eq-checking-mode checking checking = tt
eq-checking-mode synthesizing synthesizing = tt
eq-checking-mode untyped untyped = tt
eq-checking-mode _ _ = ff

------------------------------------------------------
-- functions intended for building terms for testing
------------------------------------------------------

mlam : var → term → term
mlam x t = Lam ff x nothing t

Mlam : var → term → term
Mlam x t = Lam Erased x nothing t

mappe : term → term → term
mappe t1 t2 = AppE t1 (Ttm t2)

mapptp : term → type → term
mapptp t T = AppE t (Ttp T)

mall : var → tpkd → type → type
mall = TpAbs tt

mpi : var → tpkd → type → type
mpi  = TpAbs ff

imps-to-cmds : imports → cmds
imps-to-cmds = map CmdImport

cmds-to-imps : cmds → imports
cmds-to-imps [] = []
cmds-to-imps (CmdImport i :: cs) = i :: cmds-to-imps cs
cmds-to-imps (_ :: cs) = cmds-to-imps cs

ex-cmds-to-imps : ex-cmds → ex-imports
ex-cmds-to-imps [] = []
ex-cmds-to-imps (ExCmdImport i :: cs) = i :: ex-cmds-to-imps cs
ex-cmds-to-imps (_ :: cs) = ex-cmds-to-imps cs


split-var-h : 𝕃 char → 𝕃 char × 𝕃 char
split-var-h [] = [] , []
split-var-h (qual-global-chr :: xs) = [] , xs
split-var-h (x :: xs) with split-var-h xs
... | xs' , ys = (x :: xs') , ys

split-var : var → var × var
split-var v with split-var-h (reverse (string-to-𝕃char v))
... | xs , ys = 𝕃char-to-string (reverse ys) , 𝕃char-to-string (reverse xs)

var-suffix : var → maybe var
var-suffix v with split-var v
... | "" , _ = nothing
... | _ , sfx = just sfx

-- unique qualif domain prefixes
qual-pfxs : qualif → 𝕃 var
qual-pfxs q = uniq (prefixes (trie-strings q))
  where
  uniq : 𝕃 var → 𝕃 var
  uniq vs = stringset-strings (stringset-insert* empty-stringset vs)
  prefixes : 𝕃 var → 𝕃 var
  prefixes [] = []
  prefixes (v :: vs) with split-var v
  ... | "" , sfx = vs
  ... | pfx , sfx = pfx :: prefixes vs

unqual-prefix : qualif → 𝕃 var → var → var → var
unqual-prefix q [] sfx v = v
unqual-prefix q (pfx :: pfxs) sfx v
  with trie-lookup q (pfx # sfx)
... | just (v' , _) = if v =string v' then pfx # sfx else v
... | nothing = v

unqual-bare : qualif → var → var → var
unqual-bare q sfx v with trie-lookup q sfx
... | just (v' , _) = if v =string v' then sfx else v
... | nothing = v

unqual-local : var → var
unqual-local v = f' (string-to-𝕃char v) where
  f : 𝕃 char → maybe (𝕃 char)
  f [] = nothing
  f ('@' :: t) = f t maybe-or just t
  f (h :: t) = f t
  f' : 𝕃 char → string
  f' (meta-var-pfx :: t) = maybe-else' (f t) v (𝕃char-to-string ∘ _::_ meta-var-pfx)
  f' t = maybe-else' (f t) v 𝕃char-to-string

unqual-all : qualif → var → string
unqual-all q v with var-suffix v
... | nothing = v
... | just sfx = unqual-bare q sfx (unqual-prefix q (qual-pfxs q) sfx v)

-- Given a qualified variable and a function that renames it,
-- we strip away the qualification prefix, call the function,
-- then prepend the prefix to the result
reprefix : (var → var) → var → var
reprefix f x =
  maybe-else' (pfx (string-to-𝕃char x) [])
    (f x) $ uncurry λ p s → p ^ f s where
  ret : 𝕃 char → 𝕃 char → maybe (var × var)
  ret pfx sfx = just (𝕃char-to-string (reverse pfx) , 𝕃char-to-string sfx)
  pfx : 𝕃 char → 𝕃 char → maybe (var × var)
  pfx (qual-global-chr :: xs) acc =
    pfx xs (qual-global-chr :: acc) maybe-or ret (qual-global-chr :: acc) xs
  pfx (qual-local-chr :: xs) acc =
    pfx xs (qual-local-chr :: acc) maybe-or ret (qual-local-chr :: acc) xs
  pfx (x :: xs) acc = pfx xs (x :: acc)
  pfx [] pfx = nothing

data-to/ = reprefix ("to/" ^_)
data-Is/ = reprefix ("Is/" ^_)
data-is/ = reprefix ("is/" ^_)
mu-Type/ = reprefix ("Type/" ^_)
mu-isType/ = reprefix ("isType/" ^_)




num-gt : num → ℕ → 𝕃 string
num-gt n n' = maybe-else [] (λ n'' → if n'' > n' then [ n ] else []) (string-to-ℕ n)
nums-gt : 𝕃 num → ℕ → 𝕃 string
nums-gt [] n' = []
nums-gt (n :: ns) n' =
  maybe-else [] (λ n'' → if n'' > n' || iszero n'' then [ n ] else []) (string-to-ℕ n)
  ++ nums-gt ns n'

nums-to-stringset : 𝕃 num → stringset × 𝕃 string {- Repeated numbers -}
nums-to-stringset [] = empty-stringset , []
nums-to-stringset (n :: ns) with nums-to-stringset ns
...| ss , rs = if stringset-contains ss n
  then ss , n :: rs
  else stringset-insert ss n , rs

optNums-to-stringset : maybe (𝕃 num) → maybe stringset × (ℕ → maybe string)
optNums-to-stringset nothing = nothing , λ _ → nothing
optNums-to-stringset (just ns) with nums-to-stringset ns
...| ss , [] = just ss , λ n → case nums-gt ns n of λ where
  [] → nothing
  ns-g → just ("Occurrences not found: " ^ 𝕃-to-string id ", " ns-g ^ " (total occurrences: " ^ ℕ-to-string n ^ ")")
...| ss , rs = just ss , λ n →
  just ("The list of occurrences contains the following repeats: " ^ 𝕃-to-string id ", " rs)

def-var : ex-def → var
def-var (ExDefTerm _ x _ _) = x
def-var (ExDefType _ x _ _) = x


-- expression descriptor
data exprd : Set where
  TERM : exprd
  TYPE : exprd
  KIND : exprd
--  TPKD : exprd

⟦_⟧ : exprd → Set
⟦ TERM ⟧ = term
⟦ TYPE ⟧ = type
⟦ KIND ⟧ = kind
--⟦ TPKD ⟧ = tpkd

⟦_⟧' : exprd → Set
⟦ TERM ⟧' = ex-tm
⟦ TYPE ⟧' = ex-tp
⟦ KIND ⟧' = ex-kd
--⟦ TPKD ⟧' = ex-tk

exprd-name : exprd → string
exprd-name TERM = "term"
exprd-name TYPE = "type"
exprd-name KIND = "kind"

infixl 12 _-tk_ _-tk'_ _-tT_ _-tT'_

_-tk_ : (∀ {ed} → ⟦ ed ⟧ → ⟦ ed ⟧) → tpkd → tpkd
f -tk Tkt T = Tkt (f T)
f -tk Tkk k = Tkk (f k)

_-tk'_ : ∀ {X : Set} → (∀ {ed : exprd} → ⟦ ed ⟧ → X) → tpkd → X
f -tk' Tkt T = f T
f -tk' Tkk k = f k

_-tT_ : (∀ {ed} → ⟦ ed ⟧ → ⟦ ed ⟧) → tmtp → tmtp
f -tT Ttm t = Ttm (f t)
f -tT Ttp T = Ttp (f T)

_-tT'_ : ∀ {X : Set} → (∀ {ed : exprd} → ⟦ ed ⟧ → X) → tmtp → X
f -tT' Ttm t = f t
f -tT' Ttp T = f T

tag : Set
tag = string × rope

tagged-val : Set
tagged-val = string × rope × 𝕃 tag

tags-to-rope : 𝕃 tag → rope
tags-to-rope [] = [[]]
tags-to-rope ((t , v) :: []) = [[ "\"" ^ t ^ "\":" ]] ⊹⊹ v
tags-to-rope ((t , v) :: ts) = [[ "\"" ^ t ^ "\":" ]] ⊹⊹ v ⊹⊹ [[ "," ]] ⊹⊹ tags-to-rope ts

-- We number these when so we can sort them back in emacs
tagged-val-to-rope : ℕ → tagged-val → rope
tagged-val-to-rope n (t , v , []) = [[ "\"" ^ t ^ "\":[\"" ^ ℕ-to-string n ^ "\",\"" ]] ⊹⊹ v ⊹⊹ [[ "\"]" ]]
tagged-val-to-rope n (t , v , tags) = [[ "\"" ^ t ^ "\":[\"" ^ ℕ-to-string n ^ "\",\"" ]] ⊹⊹ v ⊹⊹ [[ "\",{" ]] ⊹⊹ tags-to-rope tags ⊹⊹ [[ "}]" ]]

tagged-vals-to-rope : ℕ → 𝕃 tagged-val → rope
tagged-vals-to-rope n [] = [[]]
tagged-vals-to-rope n (s :: []) = tagged-val-to-rope n s
tagged-vals-to-rope n (s :: (s' :: ss)) = tagged-val-to-rope n s ⊹⊹ [[ "," ]] ⊹⊹ tagged-vals-to-rope (suc n) (s' :: ss)


make-tag : (name : string) → (values : 𝕃 tag) → (start : ℕ) → (end : ℕ) → tag
make-tag name vs start end = name , [[ "{\"start\":\"" ^ ℕ-to-string start ^ "\",\"end\":\"" ^ ℕ-to-string end ^ "\"" ]] ⊹⊹ vs-to-rope vs ⊹⊹ [[ "}" ]]
  where
    vs-to-rope : 𝕃 tag → rope
    vs-to-rope [] = [[]]
    vs-to-rope ((t , v) :: ts) = [[ ",\"" ^ t ^ "\":\"" ]] ⊹⊹ v ⊹⊹ [[ "\"" ]] ⊹⊹ vs-to-rope ts

pos-tm-to-tm : pos-tm → ex-tm
pos-tm-to-tm (PosTm t pi) = t

case-arg-erased : case-arg-sym → erased?
case-arg-erased CaseArgTm = ff
case-arg-erased _ = tt
