state1:
  test.succeed_with_changes

state2:
  test.succeed_with_changes
    - require:
        - state1

state3:
  test.succeed_with_changes
      onchanges:
        - state
        - test: state2

state4:
  test.succeed_with_changes
    - prereq:
         state1

unhappy_state
  test.succeed_with_changes
    - onfail:
        state*
