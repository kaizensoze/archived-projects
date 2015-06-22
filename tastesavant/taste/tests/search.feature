Feature: Search
  In order to find things on the site
  As a user
  I want to be able to search

  Scenario: Search for a user
    Given a user named "test" exists
      And I search for a user named "test"
     Then I should see a results page showing "Test E."

  Scenario: Search for restaurant
    Given a restaurant named "Test Restaurant" exists
      And I search for a restaurant named "Test Restaurant"
     Then I should see a results page showing a restaurant named "Test Restaurant"
