var driver = test.openBrowser();
var selenium = driver.getSelenium();

var timeout = 30000;
selenium.setTimeout(timeout);

var tx = test.beginTransaction();

var step = test.beginStep("Step 1");
selenium.open("http://tahi-performance.herokuapp.com/users/sign_in");
selenium.type("id=user_login", "test-user-13@example.com");
selenium.type("id=user_password", "password");
selenium.click("name=commit");
selenium.waitForPageToLoad(timeout);
selenium.waitForElementPresent("link=Welcome back, test-user-13");
test.endStep();

test.beginStep("Step 2");
selenium.click("link=Welcome back, test-user-13");
selenium.click("link=Sign out");
selenium.waitForPageToLoad(timeout);
test.endStep();

test.endTransaction();

