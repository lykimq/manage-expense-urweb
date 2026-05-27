(* Shared page: head, CSS, nav, and content area *)

fun wrap ttl content =
    return <xml>
      <head>
        <title>{[ttl]}</title>
        <link rel="stylesheet" type="text/css" href="/base.css"/>
        <link rel="stylesheet" type="text/css" href="/dashboard.css"/>
        <link rel="stylesheet" type="text/css" href="/expense.css"/>
        <link rel="stylesheet" type="text/css" href="/logic.css"/>
        <link rel="stylesheet" type="text/css" href="/expense-detail.css"/>
        <link rel="stylesheet" type="text/css" href="/approval-queue.css"/>
      </head>

      <body>
        <nav>
          <a href="/Main/login">Login</a>
          <a href="/Main/home">Home</a>
          <a href="/Main/create">Create Expense</a>
          <a href="/Main/detail">Expense Detail</a>
          <a href="/Main/queue">Approval Queue</a>
          <a href="/Main/dashboard">Dashboard</a>          
        </nav>

        <main>
          {content}
        </main>
      </body>
    </xml>
