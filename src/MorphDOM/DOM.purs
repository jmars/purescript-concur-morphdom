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

text :: forall t5 t6. LiftWidget HTML t5 => String -> t5 t6
text str = liftWidget $ display $ [Content [] str]

type El
  = forall m a. MultiAlternative m => ShiftMap (Widget HTML) m => Array (Props Prop a) -> Array (m a) -> m a

div :: El
div = el' $ Node "div"

button :: El
button = el' $ Node "button"