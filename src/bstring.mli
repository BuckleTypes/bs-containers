
(* This file is free software, part of containers. See file "license" for more details. *)

(** {1 Basic String Utils}

    Consider using {!Containers_string.KMP} for pattern search, or Regex
    libraries. *)


(*-- Start stdlib string, from https://github.com/ocaml/ocaml/blob/4.02.3/stdlib/string.mli --*)

external get : string -> int -> char = "%string_safe_get"
(** [String.get s n] returns the character at index [n] in string [s].
    You can also write [s.[n]] instead of [String.get s n].
    Raise [Invalid_argument] if [n] not a valid index in [s]. *)

val make : int -> char -> string
(** [String.make n c] returns a fresh string of length [n],
    filled with the character [c].
    Raise [Invalid_argument] if [n < 0] or [n > ]{!Sys.max_string_length}. *)

val substring : string -> from:int -> length:int -> string
(** [String.sub s start len] returns a fresh string of length [len],
    containing the substring of [s] that starts at position [start] and
    has length [len].
    Raise [Invalid_argument] if [start] and [len] do not
    designate a valid substring of [s]. *)

val concat : string -> string list -> string
(** [String.concat sep sl] concatenates the list of strings [sl],
    inserting the separator string [sep] between each.
    Raise [Invalid_argument] if the result is longer than
    {!Sys.max_string_length} bytes. *)

val trim : string -> string
(** Return a copy of the argument, without leading and trailing
    whitespace.  The characters regarded as whitespace are: [' '],
    ['\012'], ['\n'], ['\r'], and ['\t'].  If there is neither leading nor
    trailing whitespace character in the argument, return the original
    string itself, not a copy.
    @since 4.00.0 *)

val escaped : string -> string
(** Return a copy of the argument, with special characters
    represented by escape sequences, following the lexical
    conventions of OCaml.  If there is no special
    character in the argument, return the original string itself,
    not a copy. Its inverse function is Scanf.unescaped.
    Raise [Invalid_argument] if the result is longer than
    {!Sys.max_string_length} bytes. *)

val indexOf : string -> ?from:int -> char -> int
(** [String.index_from s i c] returns the index of the
    first occurrence of character [c] in string [s] after position [i].
    [String.index s c] is equivalent to [String.index_from s 0 c].
    Raise [Invalid_argument] if [i] is not a valid position in [s].
    Raise [Not_found] if [c] does not occur in [s] after position [i]. *)

val lastIndexOf : string -> ?from:int -> char -> int
(** [String.rindex_from s i c] returns the index of the
    last occurrence of character [c] in string [s] before position [i+1].
    [String.rindex s c] is equivalent to
    [String.rindex_from s (String.length s - 1) c].
    Raise [Invalid_argument] if [i+1] is not a valid position in [s].
    Raise [Not_found] if [c] does not occur in [s] before position [i+1]. *)

val contains : string -> ?from:int -> ?to_:int -> char -> bool
(** [String.contains_from s start c] tests if character [c]
    appears in [s] after position [start].
    [String.contains s c] is equivalent to
    [String.contains_from s 0 c].
    Raise [Invalid_argument] if [start] is not a valid position in [s]. *)

val uppercase : string -> string
(** Return a copy of the argument, with all lowercase letters
    translated to uppercase, including accented letters of the ISO
    Latin-1 (8859-1) character set. *)

val lowercase : string -> string
(** Return a copy of the argument, with all uppercase letters
    translated to lowercase, including accented letters of the ISO
    Latin-1 (8859-1) character set. *)

val capitalize : string -> string
(** Return a copy of the argument, with the first character set to uppercase. *)

val uncapitalize : string -> string
(** Return a copy of the argument, with the first character set to lowercase. *)

type t = string
(** An alias for the type of strings. *)

(**/**)

(* The following is for system use only. Do not call directly. *)

external unsafeGetUnchecked : string -> int -> char = "%string_unsafe_get"
external unsafeBlitUnchecked :
  string -> int -> bytes -> int -> int -> unit
  = "caml_blit_string" "noalloc"

(*-- End stdlib string --*)


type 'a gen = unit -> 'a option
type 'a sequence = ('a -> unit) -> unit
type 'a klist = unit -> [`Nil | `Cons of 'a * 'a klist]

(** {2 Common Signature} *)

module type S = sig
  type t

  val length : t -> int

  val blit : t -> int -> Bytes.t -> int -> int -> unit
  (** Similar to {!String.blit}.
      Compatible with the [-safe-string] option.
      @raise Invalid_argument if indices are not valid *)

  (*
  val blit_immut : t -> int -> t -> int -> int -> string
  (** Immutable version of {!blit}, returning a new string.
      [blit a i b j len] is the same as [b], but in which
      the range [j, ..., j+len] is replaced by [a.[i], ..., a.[i + len]].
      @raise Invalid_argument if indices are not valid *)
     *)

  val reduce : ('a -> char -> 'a) -> 'a -> t -> 'a
  (** Fold on chars by increasing index.
      @since 0.7 *)

  (** {2 Conversions} *)

  val toSequence : t -> char sequence
  val toList : t -> char list
end

(** {2 Strings} *)

val equal : string -> string -> bool

val compare : string -> string -> int

val hash : string -> int

val makeWithInit : int -> (int -> char) -> string
(** Analog to [Array.makeWithInit]. *)

(*$T
  init 3 (fun i -> [|'a'; 'b'; 'c'|].(i)) = "abc"
  init 0 (fun _ -> assert false) = ""
*)

val reverse : string -> string
(** [rev s] returns the reverse of [s] *)

(*$Q
  Q.printable_string (fun s -> s = rev (rev s))
  Q.printable_string (fun s -> length s = length (rev s))
*)

(*$=
  "abc" (rev "cba")
  "" (rev "")
  " " (rev " ")
*)

val pad : ?side:[`Left|`Right] -> ?char:char -> int -> string -> string
(** [pad n str] ensures that [str] is at least [n] bytes long,
    and pads it on the [side] with [c] if it's not the case.
    @param side determines where padding occurs (default: [`Left])
    @param c the char used to pad (default: ' ')
    @since 0.17 *)

(*$= & ~printer:Q.Print.string
  "  42" (pad 4 "42")
  "0042" (pad ~c:'0' 4 "42")
  "4200" (pad ~side:`Right ~c:'0' 4 "42")
  "hello" (pad 4 "hello")
  "aaa" (pad ~c:'a' 3 "")
  "aaa" (pad ~side:`Right ~c:'a' 3 "")
*)

val fromChar : char -> string
(** [of_char 'a' = "a"]
    @since 0.19 *)

val fromSequence : char sequence -> string
val fromList : char list -> string
val fromArray : char array -> string

(*$T
  of_list ['a'; 'b'; 'c'] = "abc"
  of_list [] = ""
*)

val toArray : string -> char array

val find : ?start:int -> sub:string -> string -> int
(** Find [sub] in string, returns its first index or [-1].
    Should only be used with very small [sub] *)

(*$= & ~printer:string_of_int
  1 (find ~sub:"bc" "abcd")
  ~-1 (find ~sub:"bc" "abd")
  1 (find ~sub:"a" "_a_a_a_")
  6 (find ~sub:"a" ~start:5 "a1a234a")
*)

(*$Q & ~count:10_000
  Q.(pair printable_string printable_string) (fun (s1,s2) -> \
    let i = find ~sub:s2 s1 in \
    i < 0 || String.sub s1 i (length s2) = s2)
*)

val findAll : ?start:int -> sub:string -> string -> int gen
(** [find_all ~sub s] finds all occurrences of [sub] in [s], even overlapping
    instances.
    @param start starting position in [s] *)

val findAllList : ?start:int -> sub:string -> string -> int list
(** [find_all ~sub s] finds all occurrences of [sub] in [s] and returns
    them in a list
    @param start starting position in [s] *)

(*$= & ~printer:Q.Print.(list int)
  [1; 6] (find_all_l ~sub:"bc" "abc aabc  aab")
  [] (find_all_l ~sub:"bc" "abd")
  [76] (find_all_l ~sub:"aaaaaa" \
    "aabbaabbaaaaabbbbabababababbbbabbbabbaaababbbaaabaabbaabbaaaabbababaaaabbaabaaaaaabbbaaaabababaabaaabbaabaaaabbababbaabbaaabaabbabababbbaabababaaabaaababbbaaaabbbaabaaababbabaababbaabbaaaaabababbabaababbbaaabbabbabababaaaabaaababaaaaabbabbaabbabbbbbbbbbbbbbbaabbabbbbbabbaaabbabbbbabaaaaabbababbbaaaa")
*)

val includes : ?start:int -> sub:string -> string -> bool
(** [mem ~sub s] is true iff [sub] is a substring of [s] *)

(*$T
   mem ~sub:"bc" "abcd"
   not (mem ~sub:"a b" "abcd")
*)

val findReversed : sub:string -> string -> int
(** Find [sub] in string from the right, returns its first index or [-1].
    Should only be used with very small [sub] *)

(*$= & ~printer:string_of_int
  1 (rfind ~sub:"bc" "abcd")
  ~-1 (rfind ~sub:"bc" "abd")
  5 (rfind ~sub:"a" "_a_a_a_")
  4 (rfind ~sub:"bc" "abcdbcd")
  6 (rfind ~sub:"a" "a1a234a")
*)

(*$Q & ~count:10_000
  Q.(pair printable_string printable_string) (fun (s1,s2) -> \
    let i = rfind ~sub:s2 s1 in \
    i < 0 || String.sub s1 i (length s2) = s2)
*)

val replace : ?which:[`Left|`Right|`All] -> sub:string -> by:string -> string -> string
(** [replace ~sub ~by s] replaces some occurrences of [sub] by [by] in [s]
    @param which decides whether the occurrences to replace are:
      {ul
        {- [`Left] first occurrence from the left (beginning)}
        {- [`Right] first occurrence from the right (end)}
        {- [`All] all occurrences (default)}
      }
    @raise Invalid_argument if [sub = ""] *)

(*$= & ~printer:CCFun.id
  (replace ~which:`All ~sub:"a" ~by:"b" "abcdabcd") "bbcdbbcd"
  (replace ~which:`Left ~sub:"a" ~by:"b" "abcdabcd") "bbcdabcd"
  (replace ~which:`Right ~sub:"a" ~by:"b" "abcdabcd") "abcdbbcd"
  (replace ~which:`All ~sub:"ab" ~by:"hello" "  abab cdabb a") \
    "  hellohello cdhellob a"
  (replace ~which:`Left ~sub:"ab" ~by:"nope" " a b c d ") " a b c d "
  (replace ~sub:"a" ~by:"b" "1aa234a") "1bb234b"
*)

val isSubstring : sub:string -> int -> string -> int -> len:int -> bool
(** [is_sub ~sub i s j ~len] returns [true] iff the substring of
    [sub] starting at position [i] and of length [len] is a substring
    of [s] starting at position [j] *)

val repeat : string -> int -> string
(** The same string, repeated n times *)

val isPrefix : pre:string -> string -> bool
(** [prefix ~pre s] returns [true] iff [pre] is a prefix of [s] *)

(*$T
  prefix ~pre:"aab" "aabcd"
  not (prefix ~pre:"ab" "aabcd")
  not (prefix ~pre:"abcd" "abc")
*)

val isSuffix : suf:string -> string -> bool
(** [suffix ~suf s] returns [true] iff [suf] is a suffix of [s]
    @since 0.7 *)

(*$T
  suffix ~suf:"cd" "abcd"
  not (suffix ~suf:"cd" "abcde")
  not (suffix ~suf:"abcd" "cd")
*)

val chopPrefix : pre:string -> string -> string option
(** [chop_pref ~pre s] removes [pre] from [s] if [pre] really is a prefix
    of [s], returns [None] otherwise
    @since 0.17 *)

(*$= & ~printer:Q.Print.(option string)
  (Some "cd") (chop_prefix ~pre:"aab" "aabcd")
  None (chop_prefix ~pre:"ab" "aabcd")
  None (chop_prefix ~pre:"abcd" "abc")
*)

val chopSuffix : suf:string -> string -> string option
(** [chop_suffix ~suf s] removes [suf] from [s] if [suf] really is a suffix
    of [s], returns [None] otherwise
    @since 0.17 *)

(*$= & ~printer:Q.Print.(option string)
  (Some "ab") (chop_suffix ~suf:"cd" "abcd")
  None (chop_suffix ~suf:"cd" "abcde")
  None (chop_suffix ~suf:"abcd" "cd")
*)

val take : int -> string -> string
(** [take n s] keeps only the [n] first chars of [s] *)

val drop : int -> string -> string
(** [drop n s] removes the [n] first chars of [s] *)

val takeDrop : int -> string -> string * string
(** [take_drop n s = take n s, drop n s] *)

(*$=
  ("ab", "cd") (take_drop 2 "abcd")
  ("abc", "") (take_drop 3 "abc")
  ("abc", "") (take_drop 5 "abc")
*)

val lines : string -> string list
(** [lines s] returns a list of the lines of [s] (splits along '\n') *)


val unlines : string list -> string
(** [unlines l] concatenates all strings of [l], separated with '\n' *)

(*$Q
  Q.printable_string (fun s -> unlines (lines s) = s)
  Q.printable_string (fun s -> unlines_gen (lines_gen s) = s)
*)

val set : string -> int -> char -> string
(** [set s i c] creates a new string which is a copy of [s], except
    for index [i], which becomes [c].
    @raise Invalid_argument if [i] is an invalid index *)

(*$T
  set "abcd" 1 '_' = "a_cd"
  set "abcd" 0 '-' = "-bcd"
  (try ignore (set "abc" 5 '_'); false with Invalid_argument _ -> true)
*)

val forEach : (char -> unit) -> string -> unit
(** Alias to {!String.iter} *)

val forEachWithIndex : (int -> char -> unit) -> string -> unit
(** Iter on chars with their index
    @since 0.12 *)

val map : (char -> char) -> string -> string
(** Map chars
    @since 0.12 *)

val mapWithIndex : (int -> char -> char) -> string -> string
(** Map chars with their index
    @since 0.12 *)

val filterMap : (char -> char option) -> string -> string
(** @since 0.17 *)

(*$= & ~printer:Q.Print.string
  "bcef" (filter_map \
     (function 'c' -> None | c -> Some (Char.chr (Char.code c + 1))) "abcde")
*)

val filter : (char -> bool) -> string -> string

(*$= & ~printer:Q.Print.string
  "abde" (filter (function 'c' -> false | _ -> true) "abcdec")
*)

(*$Q
  Q.printable_string (fun s -> filter (fun _ -> true) s = s)
*)

val flatMap : ?sep:string -> (char -> string) -> string -> string
(** Map each chars to a string, then concatenates them all
    @param sep optional separator between each generated string *)

val forAll : (char -> bool) -> string -> bool
(** True for all chars? *)

val exists : (char -> bool) -> string -> bool
(** True for some char? *)

include S with type t := string

(** {2 Operations on 2 strings} *)

val map2 : (char -> char -> char) -> string -> string -> string
(** Map pairs of chars
    @raise Invalid_argument if the strings have not the same length
    @since 0.12 *)

val forEach2: (char -> char -> unit) -> string -> string -> unit
(** Iterate on pairs of chars
    @raise Invalid_argument if the strings have not the same length *)

val forEach2WithIndex: (int -> char -> char -> unit) -> string -> string -> unit
(** Iterate on pairs of chars with their index
    @raise Invalid_argument if the strings have not the same length *)

val reduce2: ('a -> char -> char -> 'a) -> 'a -> string -> string -> 'a
(** Fold on pairs of chars
    @raise Invalid_argument if the strings have not the same length *)

val forAll2 : (char -> char -> bool) -> string -> string -> bool
(** All pairs of chars respect the predicate?
    @raise Invalid_argument if the strings have not the same length *)

val exists2 : (char -> char -> bool) -> string -> string -> bool
(** Exists a pair of chars?
    @raise Invalid_argument if the strings have not the same length *)

(** {2 Finding}

    A relatively efficient algorithm for finding sub-strings
    @since 1.0 *)

module Find : sig
  type _ pattern

  val compile : string -> [ `Direct ] pattern

  val compileReversed : string -> [ `Reverse ] pattern

  val find : ?start:int -> pattern:[`Direct] pattern -> string -> int
  (** Search for [pattern] in the string, left-to-right
      @return the offset of the first match, -1 otherwise
      @param start offset in string at which we start *)

  val findReversed : ?start:int -> pattern:[`Reverse] pattern -> string -> int
  (** Search for [pattern] in the string, right-to-left
      @return the offset of the start of the first match from the right, -1 otherwise
      @param start right-offset in string at which we start *)
end

(** {2 Splitting} *)

module Split : sig
  val list_ : by:string -> string -> (string*int*int) list
  (** Eplit the given string along the given separator [by]. Should only
      be used with very small separators, otherwise
      use {!Containers_string.KMP}.
      @return a list of slices [(s,index,length)] that are
      separated by [by]. {!String.sub} can then be used to actually extract
      a string from the slice.
      @raise Failure if [by = ""] *)

  val sequence : by:string -> string -> (string*int*int) sequence

  (** {6 Copying functions}

      Those split functions actually copy the substrings, which can be
      more convenient but less efficient in general *)

  val listCopy : by:string -> string -> string list

  (*$T
    Split.list_cpy ~by:"," "aa,bb,cc" = ["aa"; "bb"; "cc"]
    Split.list_cpy ~by:"--" "a--b----c--" = ["a"; "b"; ""; "c"; ""]
    Split.list_cpy ~by:" " "hello  world aie" = ["hello"; ""; "world"; "aie"]
  *)

  val sequenceCopy : by:string -> string -> string sequence

  val left : by:string -> string -> (string * string) option
  (** Split on the first occurrence of [by] from the leftmost part of
      the string *)

  (*$T
    Split.left ~by:" " "ab cde f g " = Some ("ab", "cde f g ")
    Split.left ~by:"__" "a__c__e_f" = Some ("a", "c__e_f")
    Split.left ~by:"_" "abcde" = None
    Split.left ~by:"bb" "abbc" = Some ("a", "c")
    Split.left ~by:"a_" "abcde" = None
  *)

  val right : by:string -> string -> (string * string) option
  (** Split on the first occurrence of [by] from the rightmost part of
      the string
      @since 0.12 *)

  val rightOrRaise : by:string -> string -> string * string
  (** Split on the first occurrence of [by] from the rightmost part of the string
      @raise Not_found if [by] is not part of the string *)

  (*$T
    Split.right ~by:" " "ab cde f g" = Some ("ab cde f", "g")
    Split.right ~by:"__" "a__c__e_f" = Some ("a__c", "e_f")
    Split.right ~by:"_" "abcde" = None
    Split.right ~by:"a_" "abcde" = None
  *)
end

(** {2 Utils} *)

val editDistance : string -> string -> int
(** Edition distance between two strings. This satisfies the classical
    distance axioms: it is always positive, symmetric, and satisfies
    the formula [distance a b + distance b c >= distance a c] *)

(*$Q
  Q.(string_of_size Gen.(0 -- 30)) (fun s -> \
    edit_distance s s = 0)
*)

(* test that building a from s, and mutating one char of s, yields
   a string s' that is accepted by a.

   --> generate triples (s, i, c) where c is a char, s a non empty string
   and i a valid index in s
*)

(*$QR
  (
    let gen = Q.Gen.(
      3 -- 10 >>= fun len ->
      0 -- (len-1) >>= fun i ->
      string_size (return len) >>= fun s ->
      char >|= fun c -> (s,i,c)
    ) in
    let small (s,_,_) = String.length s in
    Q.make ~small gen
  )
  (fun (s,i,c) ->
    let s' = Bytes.of_string s in
    Bytes.set s' i c;
    edit_distance s (Bytes.to_string s') <= 1)
*)

(** {2 Slices} A contiguous part of a string *)

module Sub : sig
  type t = string * int * int
  (** A string, an offset, and the length of the slice *)

  val make : string -> int -> len:int -> t

  val full : string -> t
  (** Full string *)

  val copy : t -> string
  (** Make a copy of the substring *)

  val underlying : t -> string

  val sub : t -> int -> int -> t
  (** Sub-slice *)

  include S with type t := t

  (*$T
    let s = Sub.make "abcde" 1 3 in \
      Sub.fold (fun acc x -> x::acc) [] s = ['d'; 'c'; 'b']
    Sub.make "abcde" 1 3 |> Sub.copy = "bcd"
    Sub.full "abcde" |> Sub.copy = "abcde"
  *)

  (*$T
    let sub = Sub.make " abc " 1 ~len:3 in \
    "\"abc\"" = (CCFormat.to_string Sub.print sub)
  *)
end
