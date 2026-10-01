# Assignment 3 - ADT and IO

This assignment consists of five parts. Certain parts have introductory text and examples. Your tasks are marked with "**Todo**".

## Part 1. The algebra of algebraic data types ADT
Cardinality of a type counts the number of possible inhabitants.

Examples:
- `Bool` has two inhabitants: `True` and `False`
- `Maybe Bool` has three inhabitants: `Nothing`, `Just False`, `Just True`

|Name        | Definition                           | Cardinality   |  
|---         |---                                   |---            |
|Void        |`data Void`                           |0              |
|Unit        |`data () = ()`                        |1              |
|Sum         |`data Either a b = Left a \| Right b` | \|a\| + \|b\| |
|Product     |`data (a,b) = (a,b)`                  | \|a\| * \|b\| |
|Exponential |`data (a->b) = a->b`                  |  \|b\|^\|a\|  |

Given the following two data types:

`data Bool = False | True` -- has exactly 2 possible values.\
`data RGB = R | G | B`     -- has exactly 3 possible values.

**Todos:**
- How many different values exist of type `(Bool, RGB)`? Write them down.
-- Bool * RGB = 2 * 3 = 6 values.
-- (False/True, R/G/B)
- How many different values exist of type `Either Bool RGB`? Write them down.
-- Bool + RGB = 2 + 3 = 5 values.
-- Left: Bool, true and false
-- Right: RGB, R and G and B
- How many different values exist of type `RGB -> Bool`? Write them down.
-- RGB -> Bool = 2^3 = 8 values.
-- (False, False, False)
-- (False, False, True)
-- (..., ..., ...)
-- (True, True, True)

Two types `A` and `B` are isomorphic if two functions can be provided:\
`aTob :: A -> B` and `bToA :: B -> A` such that\
`aToB . bToA == idB` and `bToA . aToB == idA`

Show that the following types are isomorphic:\
a) using algebra\
b) by giving the two functions

### Example:
Show that `Either () Bool` is isomorphic to `RGB`.

**Algebra:**\
|`Either () Bool`| = |RGB| \
1 + 2 = 3\
✅  
```
aTob1 :: Either () Bool -> RGB
aTob1 (Left ()) = R
aTob1 (Right False) = G
aTob1 (Right True) = B
```
```
bToa1 :: RGB -> Either () Bool
bToa1 R = Left ()
bToa1 G = Right False
bToa1 B = Right True
```
✅ (by inspection 🧐, later we will see how to prove it.)

**Todos:**
- Show that `(Bool,a)` is isomorphic to `Either a a`.
-- Bool, a = 2 * a
-- Either a a = a + a = 2 * a

-- toEither :: (Bool, a) -> Either a a
-- toEither (False, x) = Left x
-- toEither (True,  x) = Right x

-- fromEither :: Either a a -> (Bool, a)
-- fromEither (Left x)  = (False, x)
-- fromEither (Right x) = (True,  x)

- Show that `(a -> b -> c)` is isomorphic to `(a, b) -> c`. This is un- currying.
-- both types describe functions a,b -> c

-- toUncurried :: (a -> b -> c) -> (a, b) -> c
-- toUncurried f (x, y) = f x y

-- fromUncurried :: ((a, b) -> c) -> a -> b -> c
-- fromUncurried g x y = g (x, y)

**Note:**\
Note that this topic can be explored further: One can use [taylor approximation to think about recursive structures](https://web.archive.org/web/20140222144454/http://chris-taylor.github.io/blog/2013/02/11/the-algebra-of-algebraic-data-types-part-ii) and even [derivatives of data types](http://strictlypositive.org/diff.pdf) have a useful interpretation. So be aware: This is a rabbit hole!


## Part 2. Boolean blindness
**Todo:** Read this short blog post: https://runtimeverification.com/blog/code-smell-boolean-blindness

Bottom line: Use and create new types generously to express intent and to be precise.


## Part 3. Folds
Folds ([catamorphisms](https://en.wikipedia.org/wiki/Catamorphism)) are functions to deconstruct a value.

### Maybe
A fold for the type `Maybe a` looks like this:
```
data Maybe a = Nothing | Just a

foldMaybe :: b -> (a -> b) -> Maybe a -> b
foldMaybe b _ Nothing  = b
foldMaybe _ f (Just a) = f a
```


`foldMaybe` deconstructs a value of type `Maybe a` (the third parameter).
If it is `Nothing`, the first argument `b` is returned (this can be interpreted as the default value).
If it is `Just a`, the function `f` is applied to the contained value `a` and the result is returned.

Side note: This function is defined in the `Prelude` under the name `maybe`.

Folds should reconstruct the original value if called with its value constructors.
`foldMaybe Nothing Just == id`

### Either
```
data Either a b = Left a | Right b

foldEither :: (a -> c) -> (b -> c) -> Either a b -> c
foldEither l _ (Left a) = l a
foldEither _ r (Right b) = r b
```

Side note: The function `either` is defined in the `Prelude` and the exactly the same as `foldEither`.

`Law: foldEither Left Right == id`

### List
```
-- data [a] = a : [a] | []

foldList :: (a -> b -> b) -> b -> [a] -> b
foldList _ b [] = b
foldList f b (a:as) = f a (foldList f b as)
```

Observe how the recursive part of (a : **[a]**) appears as a second parameter (a -> **b** -> b).

Side note: The function `foldr` is defined in the `Prelude` and the exactly the same as `foldList`.

`Law: foldList (:) [] == id`

### Tree
```
data Tree a = Branch (Tree a) a (Tree a) | Empty

foldTree :: (b -> a -> b -> b) -> b -> Tree a -> b
foldTree _ b Empty = b
foldTree f b (Branch l a r) = f (foldTree f b l) a (foldTree f b r)
```

Observe how the recursive part of (Branch **(Tree a)** a **(Tree a)**) appear as a further parameters (**b** -> a -> **b** -> b).

`Law: foldTree Branch Empty == id`

### Expr

Given the following data type for arithmetic expressions:
```
data Expr
    = Val Int
    | Add Expr Expr
    | Mul Expr Expr
    deriving Show
```

**Todos:** 
- Define the function `foldExpr`.
- Implement the function `eval :: Expr -> Int` only by parameterizing `foldExpr`.
- Implement the function `toString :: Expr -> String` only by parameterizing `foldExpr`.

Hint: For every value constructor of a type there is a parameter in the corresponding `fold`. 

## Part 4. hcp
**Todos:** 
- Write a small command line utility, named `hcp`, which copies text files. Use `do`-notation.
- Write an alternative implementation, named `hcp'` that omits `do`-notation.

Usage:\
`> hcp in.txt out.txt`.

**Optional:** Use `Data.ByteString.Lazy` to implement a variant which handles binary data.


## Part 5. Web Requests
In this final part, you will query the weather from https://wttr.in/.
Firing a HTTP GET request on this URL https://wttr.in/~Zürich?format=3 gives the following result:
Zürich: ☀️   +17°C

**Todo:** Your task is to write a command line tool named `wttr` which takes one of two options:
- `--help` shows usage information
- `city` the city you want to query the current weather for

Example session:
```
> wttr Brugg
Brugg: 🌫  +7°C
```

During development, it is convenient to run the code in the repl. To provide command line argument to `main` in the repl there are two possibilities:
- `cabal repl` starts ghci with all dependencies loaded.
- `:main Zurich` executes `main` with `Zurich` as argument
- `:set args Zurich` sets the arguments for the whole session
- `cabal run wttr Zurich` compiles and runs the program with the given arguments

Note: The compiled executable can be found deep within the build folder `dist-newstyle/build/<architecture>/<ghcversion>/...`

**Optional:** Store the loaded content in a text file with the city and [current time](https://hackage.haskell.org/package/time-1.13/docs/Data-Time-Clock.html#v:getCurrentTime) in the file name.

### Required functions 
The following functions are imported from `Network.HTTP.Client` and `Network.HTTP.Client.TLS`.

- `newManager tlsManagerSettings :: IO Manager`  
  An I/O program that provides an HTTPS manager.

- `parseRequest :: String -> IO Request`
  Takes a URL (String) and generates an I/O program that provides a request.

- `httpLbs :: Request -> Manager -> IO (Response L8.ByteString)`  
  Takes a request and the HTTPS manager, and generates an I/O program that provides a response.

- `responseBody :: Response body -> body`  
  Takes a response and provides its main content (in our case, a ByteString).

- `L8.putStrLn :: L8.ByteString -> IO ()`
  Prints a ByteString to the console. Imported from `Data.ByteString.Lazy.Char8`.


### Hints
- In case that Powershell does not print unicode characters correctly, try the following to change the code page:
```powershell
[Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = 
  [System.Text.Utf8Encoding]::new()  # BOM-less UTF-8
```
Source: https://stackoverflow.com/questions/65982138/use-haskell-to-output-utf8-string-in-the-powershell-on-windows-10
