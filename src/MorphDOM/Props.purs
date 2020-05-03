module Concur.MorphDOM.Props where

import Prelude

import Concur.Core.Props (Props(..))
import Effect (Effect)
import Web.Event.Internal.Types (Event)

data Prop
  = Primitive String String
  | PHandler String (Event -> Effect Unit)

type MorphProps a = Props Prop a

type Prop' a = String -> MorphProps a

mkProp :: ∀ a. String -> Prop' a
mkProp k = PrimProp <<< Primitive k

href :: ∀ a. Prop' a
href = mkProp "href"
 
id :: ∀ a. Prop' a
id = mkProp "id"

class' :: ∀ a. Prop' a
class' = mkProp "class"

src :: ∀ a. Prop' a
src = mkProp "src"

lang :: ∀ a. Prop' a
lang = mkProp "lang"

charset :: ∀ a. Prop' a
charset = mkProp "charset"

action :: ∀ a. Prop' a
action = mkProp "action"

method :: ∀ a. Prop' a
method = mkProp "method"

for :: ∀ a. Prop' a
for = mkProp "for"

type' :: ∀ a. Prop' a
type' = mkProp "type"

name :: ∀ a. Prop' a
name = mkProp "name"

value :: ∀ a. Prop' a
value = mkProp "value"

onClick :: MorphProps Event
onClick = Handler $ PHandler "click"

onChange :: MorphProps Event
onChange = Handler $ PHandler "change"

onTap :: MorphProps Event
onTap = Handler $ PHandler "tap"

onSubmit :: MorphProps Event
onSubmit = Handler $ PHandler "submit"