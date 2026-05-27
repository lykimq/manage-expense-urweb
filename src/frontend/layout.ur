(* Shared page: head, CSS, nav, and content area *)

fun wrap ttl content =
  return <xml>
    <head>
      <title>{[ttl]}</title>
      <link rel="stylesheet" type="text/css" href="/base.css"/>
      <link rel="stylesheet" type="text/css" href="/dashboard.css"/>
    </head>

    <body>
      <nav>
        <a href="/Main/home">Home</a>
        <a href="/Main/dashboard">Dashboard</a>
      </nav>

      <main>
        {content}
      </main>
    </body>
  </xml>
