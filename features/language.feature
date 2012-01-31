Feature: Multiple language support
  In order to access the site in their native language
  a user visiting waterhunting.com
  wants to indicate which language they want to use and receive messages consistently in that language.
  Browsing the site, the web pages should always be served in the language the user
  has currently selected.
  However email messages sent from the site should always use the language associated
  with the user's registration.

	Scenario: User has forgotten password.
	Given I registered via the italian version of the site
	When I am on the english version of the forgot password page
	And I fill in the forgot password form correctly and click submit
	Then a password reminder message is sent
	And the password reminder message is in italian
	But the site is in english

