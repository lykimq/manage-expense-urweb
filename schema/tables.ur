sequence user_id_seq
table users : {
    Id : int,
    FullName : string,
    Role : string,
    Email : string
}

sequence expense_id_seq
table expenses : {
    Id : int,
    Title : string,
    Amount : float,
    Category : string,
    Description : string,
    OwnerId : int,
    State : string,
    CreatedAt : time,
    UpdatedAt : time
}

sequence audit_id_seq
table audit_log : {
    Id : int,
    ExpenseId : int,
    ActorId : int,
    OldState : string,
    NewState : string,
    Comment : string,
    Stamp : time
}
