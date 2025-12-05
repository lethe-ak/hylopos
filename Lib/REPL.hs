{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE RecordWildCards #-}

module Lib.REPL where

import System.IO
import Database.SQLite.Simple
-- import Data.Maybe
-- import Data.Time
-- import Data.List
import qualified Data.Text.IO as TI

-- import Lib.DB
-- import Lib.Sort
import Lib.Actions as Act

main_repl :: Connection -> IO ()
main_repl connection =  putStrLn "--- todo REPL ---"
	>> hSetBuffering stdin  NoBuffering >> hSetBuffering stdout NoBuffering >> f
	where
	f = do
		putStr "\n(show/insert/drop/quit) > "
		cmd <- getLine
		case cmd of
			"show"   -> print_tasks connection >> main_repl connection
			"insert" -> ins >> main_repl connection
			"drop"   -> print_tasks connection >> drp >> main_repl connection
			"quit"   -> putStrLn "quit."
			""       -> main_repl connection
			_        -> putStrLn "unknown command" >> main_repl connection

		where
		ins = do
			TI.putStr "title: "
			title <- TI.getLine
			TI.putStr "priority: "
			prior <- TI.getLine
			TI.putStr "dependency: "
			depends <- TI.getLine
			TI.putStr "groups: "
			groups  <- TI.getLine

			Act.insert connection [title, prior, depends, groups]

		drp = do
			putStr "plz id: "
			id' <- TI.getLine -- readが成功する事を保証するかエラーハンドリングが必要
			Act.drop connection id'
