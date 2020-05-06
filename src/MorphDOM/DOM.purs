module Concur.MorphDOM.DOM where

import Prelude

import Concur.Core (class LiftWidget, Widget, liftWidget)
import Concur.Core.DOM (el, el', elLeaf) as CD
import Concur.Core.Props (Props)
import Concur.Core.Types (display)
import Concur.MorphDOM.Props (Prop)
import Control.MultiAlternative (class MultiAlternative)
import Control.ShiftMap (class ShiftMap)

type HTML = Array VNode

data VNode
  = Content (Array Prop) String
  | Leaf String (Array Prop)
  | Node String (Array Prop) (Array VNode)
  | Empty

viewAdapter
  :: forall ps vs res
  .  (ps -> vs -> res)
  -> (ps -> vs -> Array res)
viewAdapter f = \ps vs -> [f ps vs]

el
  :: forall m a p v
  .  ShiftMap (Widget (Array v)) m
  => (Array p -> Array v -> v)
  -> Array (Props p a)
  -> m a
  -> m a
el f = CD.el (viewAdapter f)

el'
  :: forall m a p v
  .  ShiftMap (Widget (Array v)) m
  => MultiAlternative m
  => (Array p -> Array v -> v)
  -> Array (Props p a)
  -> Array (m a)
  -> m a
el' f = CD.el' (viewAdapter f)

elLeaf
  :: forall p v m a
  .  LiftWidget (Array v) m
  => (Array p -> v)
  -> Array (Props p a)
  -> m a
elLeaf f = CD.elLeaf (\ps -> [f ps])

text :: forall m a. LiftWidget HTML m => String -> m a
text str = liftWidget $ display $ [Content [] str]

style :: forall m a. LiftWidget (Array VNode) m => Array Prop -> String -> m a
style props str = liftWidget $ display $ [Node "style" props [Content [] str]]

script :: forall m a. LiftWidget (Array VNode) m => Array Prop -> String -> m a
script props str = liftWidget $ display $ [Node "style" props [Content [] str]]

type El
  = forall m a. MultiAlternative m => ShiftMap (Widget HTML) m => Array (Props Prop a) -> Array (m a) -> m a

type Ell =
  forall m a. LiftWidget (Array VNode) m => Array (Props Prop a) -> m a

html :: El
html = el' $ Node "html"

a :: El
a = el' $ Node "a"

div :: El
div = el' $ Node "div"

button :: El
button = el' $ Node "button"

body :: El
body = el' $ Node "body"

head :: El
head = el' $ Node "head"

meta :: Ell
meta = elLeaf $ Leaf "meta"

form :: El
form = el' $ Node "form"

h1 :: El
h1 = el' $ Node "h1"

h2 :: El
h2 = el' $ Node "h2"

h3 :: El
h3 = el' $ Node "h3"

h4 :: El
h4 = el' $ Node "h4"

h5 :: El
h5 = el' $ Node "h5"

h6 :: El
h6 = el' $ Node "h6"

label :: El
label = el' $ Node "label"

img :: Ell
img = elLeaf $ Leaf "img"

input :: Ell
input = elLeaf $ Leaf "input"

p :: El
p = el' $ Node "p"

empty :: Ell
empty = elLeaf $ \ _ -> Empty