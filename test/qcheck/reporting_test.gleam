import birdie
import exception
import qcheck/internal/reporting

pub fn reporting_panics_test() {
  let assert Error(exn) =
    exception.rescue(fn() { panic as "there was a panic" })

  let msg = case exn {
    exception.Errored(dyn) | exception.Exited(dyn) | exception.Thrown(dyn) ->
      reporting.test_failed_message(
        dyn,
        original_value: 1234,
        shrunk_value: 0,
        shrink_steps: 1,
      )
  }

  birdie.snap(msg, "reporting_test.reporting_panics_test")
}

pub fn reporting_assertion_errors_test() {
  let assert Error(exn) =
    exception.rescue(fn() {
      let x = 10
      let y = 2
      assert x == y
    })

  let msg = case exn {
    exception.Errored(dyn) | exception.Exited(dyn) | exception.Thrown(dyn) ->
      reporting.test_failed_message(
        dyn,
        original_value: 10,
        shrunk_value: 0,
        shrink_steps: 1,
      )
  }

  birdie.snap(msg, "reporting_test.reporting_assertion_errors_test")
}
