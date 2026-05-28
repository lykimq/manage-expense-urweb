val groupName = "state"

(* show law: each constructor stringifies to its constructor name. *)
val showSubmittedString =
    Test_harness.mkResult "show renders Submitted as Submitted"
        (show State.Submitted = "Submitted")

val showApprovedString =
    Test_harness.mkResult "show renders Approved as Approved"
        (show State.Approved = "Approved")

val showRejectedString =
    Test_harness.mkResult "show renders Rejected as Rejected"
        (show State.Rejected = "Rejected")

val showPaidString =
    Test_harness.mkResult "show renders Paid as Paid"
        (show State.Paid = "Paid")

(* SQL storage relies on each state having a distinct string form. *)
val showStringsAreUnique =
    Test_harness.mkResult "all state strings are unique"
        (show State.Submitted <> show State.Approved
         && show State.Submitted <> show State.Rejected
         && show State.Submitted <> show State.Paid
         && show State.Approved <> show State.Rejected
         && show State.Approved <> show State.Paid
         && show State.Rejected <> show State.Paid)

(* Round-trip law: fromString (show s) = Some s for every constructor. *)
val roundTripSubmitted =
    Test_harness.mkResult "fromString round trip works for Submitted"
        (case State.fromString (show State.Submitted) of
             Some State.Submitted => True
           | _ => False)

val roundTripApproved =
    Test_harness.mkResult "fromString round trip works for Approved"
        (case State.fromString (show State.Approved) of
             Some State.Approved => True
           | _ => False)

val roundTripRejected =
    Test_harness.mkResult "fromString round trip works for Rejected"
        (case State.fromString (show State.Rejected) of
             Some State.Rejected => True
           | _ => False)

val roundTripPaid =
    Test_harness.mkResult "fromString round trip works for Paid"
        (case State.fromString (show State.Paid) of
             Some State.Paid => True
           | _ => False)

(* Negative parses: unknown labels yield None. *)
val invalidStringReturnsNone =
    Test_harness.mkResult "invalid state string returns None"
        (case State.fromString "NotAState" of
             None => True
           | _ => False)

val emptyStringReturnsNone =
    Test_harness.mkResult "empty state string returns None"
        (case State.fromString "" of
             None => True
           | _ => False)

(* Case sensitivity: only the exact constructor names are accepted. *)
val lowercaseRejected =
    Test_harness.mkResult "lowercase state string is rejected"
        (case State.fromString "submitted" of
             None => True
           | _ => False)

val uppercaseRejected =
    Test_harness.mkResult "uppercase state string is rejected"
        (case State.fromString "SUBMITTED" of
             None => True
           | _ => False)

(* Whitespace sensitivity: surrounding spaces are not trimmed. *)
val leadingWhitespaceRejected =
    Test_harness.mkResult "leading whitespace in state string is rejected"
        (case State.fromString " Submitted" of
             None => True
           | _ => False)

val trailingWhitespaceRejected =
    Test_harness.mkResult "trailing whitespace in state string is rejected"
        (case State.fromString "Submitted " of
             None => True
           | _ => False)

(* Partial overlap: prefixes and suffixes must not be accepted. *)
val prefixOnlyRejected =
    Test_harness.mkResult "state string prefix alone is rejected"
        (case State.fromString "Sub" of
             None => True
           | _ => False)

val suffixSurplusRejected =
    Test_harness.mkResult "state string with extra suffix is rejected"
        (case State.fromString "SubmittedX" of
             None => True
           | _ => False)

val results : list Test_harness.test_result =
    showSubmittedString ::
    showApprovedString ::
    showRejectedString ::
    showPaidString ::
    showStringsAreUnique ::
    roundTripSubmitted ::
    roundTripApproved ::
    roundTripRejected ::
    roundTripPaid ::
    invalidStringReturnsNone ::
    emptyStringReturnsNone ::
    lowercaseRejected ::
    uppercaseRejected ::
    leadingWhitespaceRejected ::
    trailingWhitespaceRejected ::
    prefixOnlyRejected ::
    suffixSurplusRejected ::
    []
