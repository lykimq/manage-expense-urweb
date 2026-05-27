(* Wraps server-side error bodies in the same shell and red text as login flash errors. *)

fun err body =
    Layout.wrapNoNav "Error"
      <xml>
        <article>
          <header>
            <h2>Something went wrong</h2>
            {body}
          </header>
          <p><a href="/Main/home">Back to Home</a></p>
        </article>
      </xml>
