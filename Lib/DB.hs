{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE RecordWildCards #-}

module Lib.DB where

import Database.SQLite.Simple
import Lib.Types
import qualified Data.Text.IO as TI
import qualified Data.Text as T hiding (Text)
import Data.Text (Text)
import Data.Char
import Data.Bool

import Control.Monad (unless)

fetch_all :: Connection -> IO ([Task], [Dependency], [TaskGroup])
fetch_all conn = (,,) <$> query_ conn "SELECT * FROM tasks"
	<*> query_ conn "SELECT * FROM dependencies"
	<*> query_ conn "SELECT * FROM task_groups"

insert_task :: Connection -> Task -> [TaskID] -> [Text] -> IO Task
insert_task conn task parent_ids group_names = withTransaction conn $ do
	execute conn "insert into tasks (title,description,priority,created_at,deadline) VALUES (?,?,?,?,?)" task
	created_id <- fromIntegral <$> lastInsertRowId conn
	let deps = map (\pid -> Dependency { parent_id = pid, child_id = created_id }) parent_ids
	let groups = map (\name -> TaskGroup { group_name = name, task_id = created_id }) group_names
	unless (null deps) $
		executeMany conn "INSERT INTO dependencies (parent_id, child_id) VALUES (?,?)" deps
	unless (null groups) $
		executeMany conn "INSERT INTO task_groups (group_name, task_id) VALUES (?,?)" groups

	return $ case task of
		Task{..} -> Task { task_id = Just created_id, .. }

-- drop_taskという関数名からtaskは固定で良い
-- テーブルを引数に取るdrop関数に抽象化しても良いが今回はFOREIGN KEY制約を課しているので使う事はない
drop_task :: Connection -> Int -> IO ()
drop_task conn id' = execute conn "DELETE FROM tasks WHERE id == ?" (Only id') >> return ()

-- database.dbをロード、なければ作成してロード
db :: IO Connection
db = open "databases/database.db"
initialize :: Connection -> IO()
initialize connection = do
	statements <- filter (not . T.null . rm_empty) . T.split (==';') <$> TI.readFile "databases/schema.sql"
	mapM_ (execute_ connection . Query) statements
	where
	rm_empty text = let t = T.strip text in
		bool (case T.isPrefixOf "--" t of
				True  -> rm_empty . T.dropWhile isSpace . T.dropWhile (/='\n') $ text
				False -> text) "" $ T.null t

