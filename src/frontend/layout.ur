(* Shared page: head, CSS, nav, and content area *)

fun headContent ttl =
    <xml>
      <head>
        <title>{[ttl]}</title>
        <link rel="stylesheet" type="text/css" href="/base.css"/>
        <link rel="stylesheet" type="text/css" href="/dashboard.css"/>
        <link rel="stylesheet" type="text/css" href="/expense.css"/>
        <link rel="stylesheet" type="text/css" href="/logic.css"/>
        <link rel="stylesheet" type="text/css" href="/expense-detail.css"/>
        <link rel="stylesheet" type="text/css" href="/approval-queue.css"/>
      </head>
    </xml>

fun setNoCacheHeaders () =
    setHeader (blessResponseHeader "Cache-Control") "no-store, no-cache, must-revalidate, max-age=0";
    setHeader (blessResponseHeader "Pragma") "no-cache";
    setHeader (blessResponseHeader "Expires") "0"

fun wrapNoNav ttl content =
    setNoCacheHeaders ();
    return <xml>
      {headContent ttl}
      <body>
        <main>
          {content}
        </main>
      </body>
    </xml>

fun wrap ttl content =
    currentUserOpt <- Session.currentUser ();
    setNoCacheHeaders ();
    return <xml>
      {headContent ttl}

      <body>
        <nav>
          {case currentUserOpt of
               Some _ =>
               <xml>
                 <span></span>
                 <span><a href="/Main/logout">Logout</a></span>
               </xml>
             | None =>
               <xml>
                 <span><a href="/Main/login">Login</a></span>
                 <span></span>
               </xml>}
        </nav>

        <main>
          {content}
        </main>
      </body>
    </xml>
