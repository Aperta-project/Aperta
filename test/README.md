[![Code Issues](https://www.quantifiedcode.com/api/v1/project/1efd84a51e2e43b48595bbcce5d08c73/badge.svg)](https://www.quantifiedcode.com/app/project/1efd84a51e2e43b48595bbcce5d08c73)
    
# tahi-integration
Contains the base integration test framework and tahi core test cases and page object models. 

# Developers
Please read https://confluence.plos.org/confluence/display/TAHI/Running+the+QA+Automation+Tests+for+Developers
for more detailed information on getting the python test environment set up on your machine.

# Install requirements if needed

  `$ pip install -r /path/to/requirements.txt`

For mysql-connector, run:

  `$ sudo pip install --allow-external mysql-connector-python mysql-connector-python`

# Sample command to run one test (in this example, test in assess directory)

`$  python -m assess/test_assess`

For more information about the tahi specific testing approach, please see:

[Aperta QA Information](https://developer.plos.org/confluence/display/TAHI/Aperta+QA+Information)
  
For more information about the base framework, please see:

[Python-based Automated Front-end Framework] (https://developer.plos.org/confluence/display/FUNC/Python+Automated+Front+End+Framework)
