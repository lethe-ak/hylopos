{-# LANGUAGE DuplicateRecordFields #-}

module Lib.Types where

import Database.SQLite.Simple
import Data.Time (UTCTime)
import Data.Text (Text)

type TaskID   = Int
type Priority = Int

data Task = Task
	{ task_id     :: Maybe TaskID
	, title       :: Text
	, description :: Maybe Text
	, priority    :: Priority
	, created_at  :: UTCTime
	, deadline    :: Maybe UTCTime
} deriving Show

data Dependency = Dependency
	{ parent_id :: TaskID
	, child_id  :: TaskID
} deriving Show

-- TaskIDは配列で扱いたいがデータベースのスキーマに合わせた方が良いか?
data TaskGroup = TaskGroup
	{ group_name :: Text
	, task_id    :: TaskID
	-- , tasks :: [TaskID]
} deriving Show

instance FromRow Task where
	fromRow = Task <$> field <*> field <*> field <*> field <*> field <*> field
instance ToRow Task where
	toRow (Task _ b c d e f) = toRow (b,c,d,e,f)

instance FromRow Dependency where
	fromRow = Dependency <$> field <*> field
instance ToRow Dependency where
	toRow (Dependency a b) = toRow (a,b)

instance FromRow TaskGroup where
	fromRow = TaskGroup <$> field <*> field
instance ToRow TaskGroup where
	toRow (TaskGroup a b) = toRow (a,b)
