import System.Environment (getArgs)
-- import qualified Data.Text.Encoding as TE
-- import System.Posix.Env.ByteString (getArgs)

import qualified Data.Text as T
import Lib.DB
import Lib.REPL
import Lib.CLI

main :: IO ()
main = do
	connection <- db
	initialize connection

	-- getArgsがTextで取れない
	-- Stringを経由するか、このようにByteStringを経由するしかない？
	-- ただBS.getArgsはunixに限られてしまう 環境依存を避けるにはStringしかない？
	-- args <- map TE.decodeUtf8 <$> getArgs
	args <- map T.pack <$> getArgs
	if null args
		then main_repl connection
		else run_cli   connection args
