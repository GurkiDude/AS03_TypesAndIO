module Main where

import qualified Data.ByteString.Lazy.Char8 as L8
import Network.HTTP.Client
import Network.HTTP.Client.TLS
import System.Environment (getArgs)

-- Part 1: Algebra

data RGB = R | G | B deriving (Show)

-- Isomorph: (Bool, a) - Either a a

toEither :: (Bool, a) -> Either a a
toEither (False, x) = Left x
toEither (True,  x) = Right x

fromEither :: Either a a -> (Bool, a)
fromEither (Left x)  = (False, x)
fromEither (Right x) = (True,  x)

-- Isomorph: (a -> b -> c) - (a, b) -> c)

toUncurried :: (a -> b -> c) -> (a, b) -> c
toUncurried f (x, y) = f x y

fromUncurried :: ((a, b) -> c) -> a -> b -> c
fromUncurried g x y = g (x, y)

-- Part 2: Boolean blindness

filter' _    []       = []
filter' keep (a : as)
  | keep a           = a : filter' keep as
  | otherwise        =     filter' keep as

filter'' :: (a -> Bool) -> [a] -> [a]
filter'' _       []       = []
filter'' discard (a : as)
  | discard a            =     filter'' discard as
  | otherwise            = a : filter'' discard as

-- Part 3: Folds

-- Expr type
data Expr
    = Val Int
    | Add Expr Expr
    | Mul Expr Expr
    deriving Show

-- foldExpr
foldExpr :: (Int -> b) -> (b -> b -> b) -> (b -> b -> b) -> Expr -> b
foldExpr fVal fAdd fMul expr =
    case expr of
        Val n     -> fVal n
        Add l r   -> fAdd (rec l) (rec r)
        Mul l r   -> fMul (rec l) (rec r)
  where
    rec = foldExpr fVal fAdd fMul

-- eval using foldExpr
eval :: Expr -> Int
eval = foldExpr
        id          -- Val n = n
        (+)         -- Add
        (*)         -- Mul

-- toString using foldExpr
toString :: Expr -> String
toString = foldExpr
        show
        (\l r -> "(" ++ l ++ " + " ++ r ++ ")")
        (\l r -> "(" ++ l ++ " * " ++ r ++ ")")

-- Part 4: hcp
hcp :: FilePath -> FilePath -> IO ()
hcp input output = do
    content <- readFile input
    writeFile output content

hcp' :: FilePath -> FilePath -> IO ()
hcp' input output =
    readFile input >>= writeFile output

-- Part 5: Web requests
runWttr :: String -> IO ()
runWttr city = do
    manager <- newManager tlsManagerSettings
    let url = "https://wttr.in/~" ++ city ++ "?format=3"
    request <- parseRequest url
    response <- httpLbs request manager
    L8.putStrLn (responseBody response)

printHelp :: IO ()
printHelp = putStrLn $
    "Usage:\n"
    ++ "  wttr --help        Show this help\n"
    ++ "  wttr <city>        Show weather for city\n"
    ++ "  hcp <in> <out>     Copy text file\n"
    ++ "  hcp' <in> <out>    Copy text file (no do-notation)"

main :: IO ()
main = do
    args <- getArgs
    case args of

        ["--help"] ->
            printHelp

        ["wttr", city] -> do
            putStrLn $ "Loading current weather for " ++ city ++ "..."
            runWttr city

        ["hcp", inp, out] ->
            hcp inp out

        ["hcp'", inp, out] ->
            hcp' inp out

        ["expr"] -> do
            let e = Add (Val 3) (Mul (Val 2) (Val 5))
            putStrLn $ "Expression: " ++ toString e
            putStrLn $ "Value: " ++ show (eval e)

        _ ->
            putStrLn "Unknown command. Use --help."