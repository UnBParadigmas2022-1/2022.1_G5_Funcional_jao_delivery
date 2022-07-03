module Delivery where

import System.IO
import Data.List (intercalate)
import Data.List.Split (splitOn)
import System.Console.ANSI
import Data.List
import Util

import Package

data Delivery = Delivery {
  id       :: Int,
  packages :: [Int],
  status   :: String
} deriving (Show)

readDeliveriesFromFile :: IO [Delivery]
readDeliveriesFromFile = do
  file <- openFile "deliveries.txt" ReadMode
  fileContents <- hGetContents file
  let readData [id, packages, status] = Delivery (read id :: Int) (map (read::String->Int) (splitOn "," packages)) status
  let deliveries = map words $ lines fileContents
  return (map readData deliveries)

deliveryToString :: Delivery -> String
deliveryToString (Delivery id packages status) =
  (show id) ++ " " ++ (intercalate "," (map show packages)) ++ " " ++ status

createFileFromDeliveries :: [Delivery] -> IO ()
createFileFromDeliveries deliveries = do
  file <- openFile "deliveries.txt" WriteMode
  let deliveryStrings = map deliveryToString deliveries
  hPutStr file (unlines deliveryStrings)
  hClose file

addPackagesToBag :: [Package] -> [Int] -> IO [Int]
addPackagesToBag packages packagesIdList = do
  listPendingPackages packages
  putStrLn "Digite o código do pacote:"
  id <- getLine 
  -- TODO: verificar se o código existe
  let newPackagesIdList = packagesIdList ++ [read id :: Int]
  putStrLn "Produto adicionado com sucesso!"
  putStrLn "Deseja adicionar outro produto?"
  putStrLn "(s) sim (n) não"
  answer <- getLine
  -- TODO: adicionar default case
  if answer == "s"
  then do
      addPackagesToBag packages newPackagesIdList
  else return packagesIdList

registerDelivery :: [Delivery] -> [Package] -> IO ()
registerDelivery deliveries packages = do
  let packagesIds = []
  packagesIds <- addPackagesToBag packages packagesIds
  let deliveryId = (length deliveries) + 1
  let delivery = Delivery deliveryId packagesIds "entregando"
  createFileFromDeliveries (deliveries ++ [delivery])
  putStrLn "Entrega cadastrada!"
    

printDelivery :: Delivery -> IO ()
printDelivery (Delivery id packages status) = do
  let delivery = ("Identificador: " ++ (show id) ++ "\n" ++
                "Pacotes: " ++ (intercalate "," (map show packages)) ++ "\n" ++
                "Status: " ++ status ++ "\n")
  putStrLn delivery


printDeliveries :: Int -> Int -> [Delivery] -> IO ()
printDeliveries index len deliveries = do
  let delivery = deliveries !! index
  if index /= len
  then do
      printDelivery delivery
      printDeliveries (index + 1) len deliveries
  else putStrLn ("Quantidade de entregas: " ++ (show len))

listDeliveries :: [Delivery] -> IO ()
listDeliveries deliveries = do
  let len = length deliveries
  clearScreen
  putStrLn "======== STATUS ENTREGA ========"
  printDeliveries 0 len deliveries
