(* Simple error page with a message and a link back to home. *)

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
