{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE RecordWildCards #-}

module Lib.CLI where

import Database.SQLite.Simple
import Data.Text (Text)

import Lib.Actions as Act

-- usage: run_cli connection ["show"]
run_cli :: Connection -> [Text] -> IO ()
run_cli conn ["show"] = print_tasks conn

-- usage: run_cli connection ["insert", "title", "1", "1 2", "group a b"]
run_cli conn ("insert":args) = case length args of
	4 -> Act.insert conn args
	_ -> putStrLn "ERROR: wrong number of args" >> return () -- WARNING: ADHOC PATTERN

-- usage: run_cli connection ["drop", "1"]
run_cli conn ("drop":args) = case args of
	[i] -> Act.drop conn i
	_   -> putStrLn "ERROR: wrong number of args" >> return () -- WARNING: ADHOC PATTERN

-- input error
run_cli _ _ = putStrLn "ERROR: unknown error" >> return () -- WARNING: ADHOC PATTERN
