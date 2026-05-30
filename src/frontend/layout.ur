(* Shared page wrapper: title, CSS, main content, and optional nav bar. *)

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

(* The empty onload hook tells Ur/Web this is a full page so client scripts can run. *)
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

(* Same wrapper as wrapNoNav, but adds a Logout link for signed-in pages. *)
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
