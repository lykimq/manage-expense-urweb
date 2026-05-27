open Tables

type expense =
    {Id : int,
     Title : string,
     Amount : float,
     Category : string,
     Description : string,
     OwnerId : int,
     State : string,
     CreatedAt : time,
     UpdatedAt : time}

type expense_new =
    {Title : string,
     Amount : float,
     Category : string,
     Description : string,
     OwnerId : int,
     State : string}

fun rowFromExpenses r =
    {Id = r.Expenses.Id,
     Title = r.Expenses.Title,
     Amount = r.Expenses.Amount,
     Category = r.Expenses.Category,
     Description = r.Expenses.Description,
     OwnerId = r.Expenses.OwnerId,
     State = r.Expenses.State,
     CreatedAt = r.Expenses.CreatedAt,
     UpdatedAt = r.Expenses.UpdatedAt}

fun getById id =
    rowOpt <- oneOrNoRows (SELECT expenses.Id, expenses.Title, expenses.Amount,
                                  expenses.Category, expenses.Description,
                                  expenses.OwnerId, expenses.State,
                                  expenses.CreatedAt, expenses.UpdatedAt
                           FROM expenses
                           WHERE expenses.Id = {[id]});
    return (case rowOpt of
              None => None
            | Some row => Some (rowFromExpenses row))

fun getByOwner ownerId =
    query (SELECT expenses.Id, expenses.Title, expenses.Amount,
                  expenses.Category, expenses.Description,
                  expenses.OwnerId, expenses.State,
                  expenses.CreatedAt, expenses.UpdatedAt
           FROM expenses
           WHERE expenses.OwnerId = {[ownerId]})
          (fn r rows => return (rowFromExpenses r :: rows))
          []

fun getByState state =
    query (SELECT expenses.Id, expenses.Title, expenses.Amount,
                  expenses.Category, expenses.Description,
                  expenses.OwnerId, expenses.State,
                  expenses.CreatedAt, expenses.UpdatedAt
           FROM expenses
           WHERE expenses.State = {[state]})
          (fn r rows => return (rowFromExpenses r :: rows))
          []

fun create data =
    id <- nextval expense_id_seq;
    stamp <- now;
    dml (INSERT INTO expenses (Id, Title, Amount, Category, Description,
                               OwnerId, State, CreatedAt, UpdatedAt)
         VALUES ({[id]}, {[data.Title]}, {[data.Amount]}, {[data.Category]},
                 {[data.Description]}, {[data.OwnerId]}, {[data.State]},
                 {[stamp]}, {[stamp]}));
    return id

fun updateState id state stamp =
    dml (UPDATE expenses
         SET State = {[state]}, UpdatedAt = {[stamp]}
         WHERE Id = {[id]})
