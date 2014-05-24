{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

import Control.Monad.IO.Class (liftIO)
import Data.Aeson (object, (.=))
import Network.HTTP.Types.Status
import Web.Scotty
import Network.Wai.Middleware.Static
import Data.String.Utils
import Data.Monoid (mconcat)
import FileRead
import Data.Char
import Control.Parallel.Strategies
import Control.Parallel

--To run scotty and writing get and post services 
main :: IO ()
main = scotty 3000 $ do
  middleware $ staticPolicy (noDots >-> addBase "js")
  middleware $ staticPolicy (noDots >-> addBase "template")
  middleware $ staticPolicy (noDots >-> addBase "imgs")
  tempFileHolder <- liftIO readFilesFromDirectory
  
  get "/" $ do
    file "index.html"	
  post "/queryResolver2" $ do
    searchString <- param "field" `rescue` (const next)
    let temp=calculateFrequecyAndReturnSortedDocuments tempFileHolder searchString    
    json (temp)
  post "/queryResolver2" $ do
  json $ object [ "error" .= ("Invalid request" :: String) ]
  status badRequest400



calculateFrequecyAndReturnSortedDocuments :: [(String, [(String, Int)])] -> [Char] -> [(String, Int)]
calculateFrequecyAndReturnSortedDocuments mapOfList keywords =  filter (\(word,count) -> count > 0) $ runEval $ parList rdeepseq $  returnListOfDocumentsWithMaximumFrequencyOfWords mapOfList $ split " "  keywords  




returnListOfDocumentsWithMaximumFrequencyOfWords :: [(String, [(String,Int)])] -> [String] -> [(String,Int)]
returnListOfDocumentsWithMaximumFrequencyOfWords [] queryList = []
returnListOfDocumentsWithMaximumFrequencyOfWords ((filename,frequencyOfWords):xs) queryList = par x1 (par x2 (x1:x2))
											      where 
											      x1 = (filename, countWithFrequecyOfWords queryList frequencyOfWords)
										              x2 = returnListOfDocumentsWithMaximumFrequencyOfWords xs queryList 


countWithFrequecyOfWords :: Num a => [[Char]] -> [([Char], a)] -> a
countWithFrequecyOfWords [] _ = 0
countWithFrequecyOfWords (y:ys) documentFrequectOfWords =  getCountOfWordInFrequecyList y documentFrequectOfWords + countWithFrequecyOfWords ys documentFrequectOfWords


getCountOfWordInFrequecyList :: Num a => [Char] -> [([Char], a)] -> a
getCountOfWordInFrequecyList queryWord []		 = 0
getCountOfWordInFrequecyList queryWord ((word,count):xs) = 
							if queryWord==(map toLower word) then count + getCountOfWordInFrequecyList queryWord xs
							   else 0 + getCountOfWordInFrequecyList queryWord xs





