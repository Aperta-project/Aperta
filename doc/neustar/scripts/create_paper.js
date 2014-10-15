var driver = test.openBrowser();
var selenium = driver.getSelenium();

var timeout = 30000;
var title = "My favorite number: " + Number(new Date);

selenium.setTimeout(timeout);

var tx = test.beginTransaction();

var step = test.beginStep("Step 1 - Login");
selenium.open("http://tahi-performance.herokuapp.com/users/sign_in");
selenium.type("id=user_login", "test-user-13@example.com");
selenium.type("id=user_password", "password");
selenium.click("name=commit");
selenium.waitForElementPresent("link=Welcome back, testuser13");
test.endStep();

test.beginStep("Step 2 - Create Paper");
selenium.waitForElementPresent("link=Create new submission");
selenium.click("link=Create new submission");
selenium.waitForElementPresent("id=paper-short-title");
selenium.type("id=paper-short-title", title);
selenium.click("//button[@type='submit']");
selenium.waitForElementPresent("id=paper-title");
test.endStep();

test.beginStep("Step 3 - Edit Paper Title");
selenium.type("id=paper-title", title);
selenium.waitForTextPresent("Saved");
test.endStep();

test.beginStep("Step 4 - Click Paper on Dashboard");
selenium.click("css=a.nav-bar-home");
selenium.waitForElementPresent("link="+title);
selenium.click("link="+title);
test.endStep();

test.endTransaction();
