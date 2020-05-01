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

onClick :: MorphProps Event
onClick = Handler $ PHandler "click"