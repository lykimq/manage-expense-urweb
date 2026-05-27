val login : int -> transaction unit
val logout : unit -> transaction unit
val currentUser : unit -> transaction (option int)
val requireUser : unit -> transaction int
