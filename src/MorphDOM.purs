module Concur.MorphDOM where

import Prelude

import Concur.Core.Discharge (discharge, dischargePartialEffect)
import Concur.Core.Types (Widget)
import Concur.MorphDOM.DOM (VNode(..), HTML)
import Concur.MorphDOM.Props (Prop(..))
import Data.Array.NonEmpty (NonEmptyArray, fromArray, head, tail)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.String (joinWith)
import Data.Traversable (foldl, sequence)
import Data.Tuple (fst, snd)
import Data.Tuple.Nested (type (/\), (/\))
import Effect (Effect, foreachE)
import Effect.Class.Console (log)
import Effect.Uncurried (EffectFn3, runEffectFn3)
import Web.DOM (Document, Element, Node)
import Web.DOM.Document (createElement, createTextNode)
import Web.DOM.Element (setAttribute, toEventTarget, toNode)
import Web.DOM.Node (appendChild)
import Web.DOM.NonElementParentNode (getElementById)
import Web.DOM.Text (toNode) as T
import Web.Event.Event (EventType(..))
import Web.Event.EventTarget (EventListener, EventTarget, addEventListener, eventListener)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toDocument, toNonElementParentNode)
import Web.HTML.Window (document)

foreign import _morphdom :: EffectFn3 Element Element NodeListeners Unit
 
morphdom :: Element -> Element -> NodeListeners -> Effect Unit
morphdom = runEffectFn3 _morphdom

type Listener a = {
  t :: String,
  l :: EventListener
  | a
}

type Listeners = Array (Listener ())
type NodeListeners = Array (Listener ( n :: EventTarget ))

renderProp :: Element -> Prop -> Effect Listeners
renderProp el_ (Primitive k v) = do
  setAttribute k v el_
  pure []
renderProp el_ (PHandler t e) = do
  let typ = EventType t
  l <- eventListener e
  let target = toEventTarget el_
  addEventListener typ l false target
  pure [{ t, l }]

renderProps :: Element -> NonEmptyArray Prop -> Effect NodeListeners
renderProps ele props = do
  let p = head props
  listeners <- renderProp ele p
  let target = toEventTarget ele
  let withNode { t, l } = { t, l, n: target }
  case fromArray $ tail props of
    Nothing -> pure $ map withNode listeners
    Just rest -> do
      restListeners <- renderProps ele rest
      pure $ (map withNode listeners) <> restListeners

renderEl :: Document -> VNode -> Effect (Node /\ NodeListeners)
renderEl doc Empty = do
  e <- createTextNode "" doc
  pure $ (T.toNode e /\ [])
renderEl doc (Content props str) = do
  e <- createTextNode str doc
  c <- createElement "span" doc
  _ <- appendChild (T.toNode e) $ toNode c
  listeners <- case fromArray props of
    Nothing -> pure []
    Just ps -> renderProps c ps
  pure $ (toNode c /\ listeners)
renderEl doc (Leaf name props) = do
  e <- createElement name doc
  listeners <- case fromArray props of
    Nothing -> pure []
    Just ps -> renderProps e ps
  pure $ (toNode e /\ listeners)
renderEl doc (Node name props cs) = do
  e <- createElement name doc
  listeners <- case fromArray props of
    Nothing -> pure []
    Just ps -> renderProps e ps
  c <- renderChildren doc cs
  let childListeners = foldl (<>) [] $ map snd c
  let children = map fst c
  foreachE children $ \ a -> void $ appendChild a (toNode e)
  pure $ (toNode e /\ (listeners <> childListeners))

renderChildren :: Document -> Array VNode -> Effect (Array (Node /\ NodeListeners))
renderChildren doc ee = sequence $ map (\a -> renderEl doc a) ee

render :: Document -> Array VNode -> Effect (Element /\ NodeListeners)
render doc els = do
  fragment <- createElement "div" doc
  c <- renderChildren doc els
  let childListeners = foldl (<>) [] $ map snd c
  let children = map fst c
  foreachE children $ \ a -> void $ appendChild a (toNode fragment)
  pure $ fragment /\ childListeners

runWidgetInDom :: ∀ a. String -> Widget HTML a -> Effect Unit
runWidgetInDom elemId winit = do
  win <- window
  d <- document win
  let doc = toDocument d
  let node = toNonElementParentNode d
  mroot <- getElementById elemId node
  case mroot of
    Nothing -> pure unit
    Just root -> run root doc
  where
    run ::  Element -> Document -> Effect Unit
    run node doc = do
      winit' /\ v <- dischargePartialEffect winit
      r <- render doc $ v
      void $ morphdom node (fst r) (snd r)
      handler doc node (Right winit')
      pure unit
    handler doc node (Right r) = do
      v <- discharge (handler doc node) r
      res <- render doc v
      void $ morphdom node (fst res) (snd res)
    handler doc _ (Left err) = do
      log ("FAILED! " <> show err)
      pure unit

renderString :: Array VNode -> String
renderString = foldl (<>) "" <<< map renderStringEl
  where
    renderStringEl (Content ps s) = s
    renderStringEl Empty = ""
    renderStringEl (Leaf n ps) =
      "<" <> n <> " " <> (renderPropsString ps) <> "/>"
    renderStringEl (Node n ps vs) =
      "<" <> n <> " " <> (renderPropsString ps) <> ">" <>
        (renderString vs) <> "</" <> n <> ">"
    renderPropsString = joinWith " " <<< map renderPropString
    renderPropString (Primitive k v) = k <> "=" <> "\"" <> v <> "\""
    renderPropString (PHandler _ _) = ""

renderWidgetToString :: ∀ a. Widget HTML a -> Effect String
renderWidgetToString winit = do
  winit' /\ v <- dischargePartialEffect winit
  pure $ renderString v