{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedRecordDot #-}

module Lib.Sort where

import Data.Maybe
import Lib.Types
import Data.List

topological_sort :: [Task] -> [Dependency] -> [TaskID]
topological_sort []    _    = []
topological_sort tasks deps = do
	-- deps(依存関係リスト)の中にchild_idとして存在するTaskID すくなくとも1つのタスクに依存されている
	let children = map child_id deps
	-- 参照されていないタスク、そうでないタスク
	let (executable, dependent) = partition (\t -> case t.task_id of
			Nothing -> False
			Just i -> not (elem i children)
		) tasks

	if null executable then mapMaybe task_id' dependent else
		let executable_ids = mapMaybe task_id' executable
		    deps'          = filter (\d -> not (elem (parent_id d) executable_ids)) deps
		in executable_ids ++ topological_sort dependent deps'

	where task_id' = (\t -> t.task_id)




