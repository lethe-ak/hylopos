{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE RecordWildCards #-}

module Lib.Actions where

import Database.SQLite.Simple
import Data.Time
import Data.List hiding (words)
import Data.Maybe
import qualified Data.Text as T hiding (Text)
import Data.Text (Text)
import qualified Data.Text.IO as TI
import qualified Data.Text.Read as TR

import Lib.Sort
import Lib.DB
import Lib.Types

import Prelude hiding (words)

insert :: Connection -> [Text] -> IO ()
insert conn [title,prior,depends,groups] = do
	now <- getCurrentTime
	case text_to_decimal prior of
		Just n  -> do
			let task = Task { task_id = Nothing, title = title
				, description = Nothing, priority = n
				, created_at = now, deadline = Nothing } :: Task
			_ <- insert_task conn task (mapMaybe text_to_decimal . T.words $ depends) (T.words groups)
			return ()
		Nothing -> putStrLn "ERROR: cannot parse char" >> return () -- WARNING: ADHOC PATTERN

insert _ _ = putStrLn "ERROR: wrong number of args" >> return ()               -- WARNING: ADHOC PATTERN


drop :: Connection -> Text -> IO ()
drop conn = maybe (putStrLn "ERROR: cannot parse char" >> return ()) (drop_task conn) . text_to_decimal

print_tasks :: Connection -> IO ()
print_tasks conn = do
	(tasks, deps, groups) <- fetch_all conn
	let sorted_ids   = topological_sort tasks deps
	let sorted_tasks = mapMaybe (\tid -> find (\t -> t.task_id == Just tid) tasks) sorted_ids
	let headers = ["ID", "PRIO", "TITLE", "DEPENDS", "GROUPS"]     :: [Text]
	let rows = headers : map (print_task deps groups) sorted_tasks :: [[Text]]
	let lengths = map (maximum . map T.length) . transpose $ rows  :: [Int]
	let pads    = map (zipWith (-) lengths . map T.length) rows    :: [[Int]] -- 型を忘れるのでメモ
	mapM_ TI.putStrLn $ T.intercalate " | " <$> zipWith (\p r -> zipWith (
			\a b -> let left = div a 2
			            rep  = \n -> T.replicate n (T.singleton ' ')
			            pad  = T.concat [(rep left), b, (rep (a-left))] -- ++がないのでT.concatに
			in pad
		) p r) pads rows
	where
	print_task :: [Dependency] -> [TaskGroup] -> Task -> [Text]
	print_task deps' groups' task = do
		let taskid = case task.task_id of Just i -> i; Nothing -> 0

		let parents   = map parent_id $ filter (\d -> d.child_id == taskid) deps'
		let parentStr = T.concat ["[", T.intercalate "," (map tshow parents), "]"]

		let groups''  = map group_name $ filter (\g -> g.task_id == taskid) groups'
		let groupStr  = T.unwords groups''

		[tshow taskid, tshow task.priority, task.title, parentStr, groupStr]

	tshow = T.pack . show -- Stringを経由するのが気になる

text_to_decimal :: Integral a => Text -> Maybe a
text_to_decimal = either (\_ -> Nothing) (Just . fst) . TR.decimal
