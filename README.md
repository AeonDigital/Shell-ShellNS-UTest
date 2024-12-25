Shell-ShellNS-UTest
================================

> [Aeon Digital](http://www.aeondigital.com.br)  
> rianna@aeondigital.com.br

&nbsp;

``ShellNS UTest`` offers the minimum necessary to have unit tests.


&nbsp;
&nbsp;

________________________________________________________________________________

## Main

After downloading the repo project, go to its root directory and use one of the 
commands below

``` shell
# Loads the project in the context of the Shell.
# This will download all dependencies if necessary. 
. main.sh "run"



# Installs dependencies (this does not activate them).
. main.sh install

# Update dependencies
. main.sh update

# Removes dependencies
. main.sh uninstall




# Runs unit tests, if they exist.
. main.sh utest

# Runs the unit tests and stops them on the first failure that occurs.
. main.sh utest 1



# Export a new 'package.sh' file for use by the project in standalone mode
. main.sh export


# Exports a new 'package.sh'
# Export the manual files.
# Export the 'ns.sh' file.
. main.sh extract-all
```

&nbsp;
&nbsp;


________________________________________________________________________________

## Standalone

To run the project in standalone mode without having to download the repository 
follow the guidelines below:  

``` shell
# Download with CURL
curl -o "shellns_utest_standalone.sh" \
"https://raw.githubusercontent.com/AeonDigital/Shell-ShellNS-UTest/refs/heads/main/standalone/package.sh"

# Give execution permissions
chmod +x "shellns_utest_standalone.sh"

# Load
. "shellns_utest_standalone.sh"
```


&nbsp;
&nbsp;

________________________________________________________________________________

## How to use

This module does not run in isolation. Upload it standalone to the repository of another ShellNS package and run the unit tests using the examples below:

``` shell
# From the root directory of the ShellNS project repository being tested

# Performs the entire battery of tests:
. main.sh utest

# Ends testing on the first failure.
. main.sh utest 1
```

To learn more about running tests you can check out the technical documentation 
at 'utest/execute.sh'.


&nbsp;
&nbsp;


________________________________________________________________________________

## Licence

This project uses the [MIT License](LICENCE.md).