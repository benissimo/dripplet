Feature: Manage water points
  In order to share the location of water points
  a user visiting waterhunting.com
  wants to create a water point, indicating location and optionally including text and photo.
  
  Scenario: Register new water point with no photo
    Given I am signed in as a fully registered user
	When I am on the new water point page
	  And I fill in the water point creation form and submit
	Then a new water point is created
      And I arrive at the confirmation page
	  And I see something not yet implemented

  Scenario: Register new water point with a photo
    Given I am signed in as a fully registered user
	When I am on the new water point page
	  And I upload a valid photo with GPS
	  And I fill in the water point creation form and submit
	Then a new water point is created
	  And I arrive at the confirmation page
	  And the GPS coordinates have been parsed

    Given I am signed in as a fully registered user
	When I am on the new water point page
	  And I upload a valid photo without GPS
	  And I fill in the water point creation form and submit
	Then a new water point is created
	  And I arrive at the confirmation page
	  And the GPS coordinates are the defaults
	
    Given I am signed in as a fully registered user
	When I am on the new water point page
	  And I upload an invalid photo
	  And I fill in the water point creation form and submit
	Then an error message warns me that the photo is invalid
	  And I am still on the water point creation page
	
