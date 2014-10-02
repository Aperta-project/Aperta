var driver = test.openBrowser();
var selenium = driver.getSelenium();

var timeout = 30000;
selenium.setTimeout(timeout);

var row = csv.random();
var username = row.get("username");
var password = row.get("password");

var tx = test.beginTransaction();

var step = test.beginStep("Step 1");
selenium.open("http://tahi-performance.herokuapp.com/users/sign_in");
selenium.type("id=user_login", username);
selenium.type("id=user_password", password);
selenium.click("name=commit");
selenium.waitForPageToLoad(timeout);
selenium.waitForElementPresent("link=Welcome back, testuser13");
test.endStep();

test.beginStep("Step 2");
selenium.click("link=Welcome back, testuser13");
selenium.click("link=Sign out");
selenium.waitForPageToLoad(timeout);
test.endStep();

test.endTransaction();
