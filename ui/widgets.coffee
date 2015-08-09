
if not window?.React?
  # just so it does not fail at import time on node.js when running browserify
  React =
    DOM: {}
    createFactory: () ->
else
  React = window.React

# fbp-spec UI library
# List of tests
{ div, label, span } = React.DOM
class SuiteHeaderClass
  render: () ->
    (div {className: 'suite-header'}, [
      label {}, @props.name
      label {}, @props.component
    ])
SuiteHeader = React.createFactory SuiteHeaderClass

class SuiteHeaderClass
  render: () ->
    (div {className: 'suite-header'}, [
      label {}, @props.name
      label {}, "(#{@props.topic})" if @props.name != @props.topic
    ])
SuiteHeader = React.createFactory SuiteHeaderClass

class TestCaseListingClass
  render: () ->
    passChar = if @props.passed then '✔' else '✘'
    (div {className: "testcase-header"}, [
      (label {}, @props.name)
      (label {}, [@props.assertion, (span {}, passChar)] )
    ])
TestCaseListing = React.createFactory TestCaseListingClass

{ ul, li } = React.DOM
class TestsListingClass
  render: () ->
    createSuite = (suite) ->
      items = []
      items.push (SuiteHeader suite)
      for testcase in suite.cases
        items.push (li {}, [TestCaseListing testcase])
      return items
    (ul {className: 'horizontal-list'}, [
      @props.suites.map createSuite
    ])
TestsListing = React.createFactory TestsListingClass

# Project wide test status
countCases = (suites, predicate) ->
  count = 0
  for suite in suites
    for testcase in suite.cases
      count += 1 if predicate testcase, suite
  return count
      
class TestStatusClass
  render: () ->
    total = countCases @props.suites, () -> return true
    passing = countCases @props.suites, (c) -> return c.passed? and c.passed
    failing = countCases @props.suites, (c) -> return c.passed? and not c.passed
    skipped = countCases @props.suites, (c, s) -> return c.skip? or s.skip?
    # TODO: also consider pending
    # TODO: visualize running / not-running
    # FIXME: visualize overall pass/fail
    (ul {className: 'test-status'}, [
      (li {className: 'pass'}, passing)
      (li {className: 'fail'}, failing)
      (li {className: 'skip'}, skipped)
      (li {className: 'total'}, total)
    ])

TestStatus = React.createFactory TestStatusClass

module.exports =
  TestStatus: TestStatus
  TestsListing: TestsListing