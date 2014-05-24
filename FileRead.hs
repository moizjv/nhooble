module FileRead where
import Data.List (sort, group, sortBy, groupBy)
import Data.List.Split
import Control.Arrow ((&&&))
import Control.Parallel
import Control.Parallel.Strategies
import System.Directory
import Data.String.Utils

--Reading file from directory in parallel
readFilesFromDirectory :: IO [([Char], [([Char], Int)])]
readFilesFromDirectory = do
	allFiles <- getDirectoryContents "docs"
	let filtered = filter (endswith ".htm") allFiles
	listOfTuplesWithFileContent <- combingReadFiles $ readingFilesInParallel filtered
	return listOfTuplesWithFileContent

--Mapper takes String and returns list of tuple containing word and its frequency.
mapper :: String -> [(String,Int)] 
mapper str = getCountOFWords (splitOn " " str)

-- Takes String and returns list of tuple containing word and its frequency
getCountOFWords :: [String] -> [(String,Int)]
getCountOFWords = map (head &&& length) . group . sort
	
--To strip html files
stripTags :: String -> String
stripTags []         = []
stripTags ('<' : xs) = stripTags $ drop 1 $ dropWhile (/= '>') xs
stripTags (x : xs)   = x : stripTags xs

--using sequence which will convert [IO a] to IO [a] i.e. unwraping all file reads and wrapping it together.
combingReadFiles :: Monad m => [m a] -> m [a]
combingReadFiles input = sequence input

--Magical parMap and rpar for performing parallel map read
readingFilesInParallel :: [[Char]] -> [IO ([Char], [(String, Int)])]
readingFilesInParallel names = parMap rpar (\x -> do
					   temp <- readFile $ "docs/" ++ x
					   return (x, mapper $ stripTags $ temp)) names					  

--Operation of reading files.
readingFiles :: [[Char]] -> IO [([Char], [(String, Int)])]
readingFiles []	     = return []
readingFiles (x:xs)  = do			
			temp <- readFile $ "docs/" ++ x
			rest <- readingFiles xs
			return ((x, mapper $ stripTags $ temp):rest)  
