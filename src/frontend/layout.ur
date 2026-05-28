(* Page shell: head, CSS, main content, optional nav. *)

fun headContent ttl =
    <xml>
      <head>
        <title>{[ttl]}</title>
        <link rel="stylesheet" type="text/css" href="/base.css"/>
        <link rel="stylesheet" type="text/css" href="/dashboard.css"/>
        <link rel="stylesheet" type="text/css" href="/expense.css"/>
        <link rel="stylesheet" type="text/css" href="/login.css"/>
        <link rel="stylesheet" type="text/css" href="/expense-detail.css"/>
        <link rel="stylesheet" type="text/css" href="/approval-queue.css"/>
      </head>
    </xml>

(* Empty onload marks the page client-side so app.urp script tags (e.g. bfcache.js) load. *)
fun wrapNoNav ttl content =
    Session.setNoCacheHeaders ();
    return <xml>
      {headContent ttl}
      <body onload={return ()}>
        <main>
          {content}
        </main>
      </body>
    </xml>

(* Logged-in shell with logout. *)
fun wrap ttl content =
    Session.setNoCacheHeaders ();
    return <xml>
      {headContent ttl}
      <body onload={return ()}>
        <nav>
          <span></span>
          <span><a href="/Main/logout">Logout</a></span>
        </nav>
        <main>
          {content}
        </main>
      </body>
    </xml>
